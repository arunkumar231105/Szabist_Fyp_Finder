const express = require('express');
const router  = express.Router();
const db      = require('../config/db');

const toArr = (s) => s ? s.split(',').map(x=>x.trim()).filter(Boolean) : [];
const toStr = (a) => Array.isArray(a) ? a.join(',') : (a||'');

const fmt = (r) => ({
  id: r.id, ownerName: r.owner_name, ownerId: r.owner_id,
  ownerDept: r.owner_dept, title: r.title, description: r.description,
  technologiesRequired: toArr(r.technologies_required),
  skillsRequired: toArr(r.skills_required),
  status: r.status, createdAt: r.created_at,
});

// GET all (optional ?status=open)
router.get('/', async (req,res) => {
  try {
    const {status} = req.query;
    let sql='SELECT * FROM ideas', params=[];
    if(status){ sql+=' WHERE status=?'; params=[status]; }
    sql+=' ORDER BY created_at DESC';
    const [rows] = await db.query(sql,params);
    res.json({success:true,count:rows.length,data:rows.map(fmt)});
  } catch(e){ res.status(500).json({success:false,message:e.message}); }
});

// GET one
router.get('/:id', async (req,res) => {
  try {
    const [rows] = await db.query('SELECT * FROM ideas WHERE id=?',[req.params.id]);
    if(!rows.length) return res.status(404).json({success:false,message:'Idea not found'});
    res.json({success:true,data:fmt(rows[0])});
  } catch(e){ res.status(500).json({success:false,message:e.message}); }
});

// POST create
router.post('/', async (req,res) => {
  try {
    const {ownerName,ownerId,ownerDept,title,description,
           technologiesRequired,skillsRequired,status} = req.body;
    if(!ownerName||!ownerId||!title||!description)
      return res.status(400).json({success:false,message:'ownerName, ownerId, title, description required'});
    const [r] = await db.query(
      `INSERT INTO ideas (owner_name,owner_id,owner_dept,title,description,
       technologies_required,skills_required,status) VALUES (?,?,?,?,?,?,?,?)`,
      [ownerName,ownerId,ownerDept||'',title,description,
       toStr(technologiesRequired),toStr(skillsRequired),status||'open']
    );
    res.status(201).json({success:true,message:'Idea created',data:{id:r.insertId}});
  } catch(e){ res.status(500).json({success:false,message:e.message}); }
});

// PUT update
router.put('/:id', async (req,res) => {
  try {
    const [check] = await db.query('SELECT id FROM ideas WHERE id=?',[req.params.id]);
    if(!check.length) return res.status(404).json({success:false,message:'Idea not found'});
    const {ownerName,ownerId,ownerDept,title,description,
           technologiesRequired,skillsRequired,status} = req.body;
    await db.query(
      `UPDATE ideas SET owner_name=?,owner_id=?,owner_dept=?,title=?,description=?,
       technologies_required=?,skills_required=?,status=? WHERE id=?`,
      [ownerName,ownerId,ownerDept||'',title,description,
       toStr(technologiesRequired),toStr(skillsRequired),status||'open',
       req.params.id]
    );
    res.json({success:true,message:'Idea updated successfully'});
  } catch(e){ res.status(500).json({success:false,message:e.message}); }
});

// DELETE
router.delete('/:id', async (req,res) => {
  try {
    const [check] = await db.query('SELECT id FROM ideas WHERE id=?',[req.params.id]);
    if(!check.length) return res.status(404).json({success:false,message:'Idea not found'});
    await db.query('DELETE FROM ideas WHERE id=?',[req.params.id]);
    res.json({success:true,message:'Idea deleted successfully'});
  } catch(e){ res.status(500).json({success:false,message:e.message}); }
});

module.exports = router;
