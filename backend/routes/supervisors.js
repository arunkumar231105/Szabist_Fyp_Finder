const express = require('express');
const router  = express.Router();
const db      = require('../config/db');

const toArr = (s) => s ? s.split(',').map(x=>x.trim()).filter(Boolean) : [];
const toStr = (a) => Array.isArray(a) ? a.join(',') : (a||'');

const fmt = (r) => ({
  id: r.id, name: r.name, email: r.email,
  department: r.department, designation: r.designation,
  specialization: toArr(r.specialization),
  availableSlots: r.available_slots,
  isAvailable: r.is_available===1,
  createdAt: r.created_at,
});

// GET all
router.get('/', async (req,res) => {
  try {
    const [rows] = await db.query('SELECT * FROM supervisors ORDER BY name ASC');
    res.json({success:true,count:rows.length,data:rows.map(fmt)});
  } catch(e){ res.status(500).json({success:false,message:e.message}); }
});

// GET one
router.get('/:id', async (req,res) => {
  try {
    const [rows] = await db.query('SELECT * FROM supervisors WHERE id=?',[req.params.id]);
    if(!rows.length) return res.status(404).json({success:false,message:'Supervisor not found'});
    res.json({success:true,data:fmt(rows[0])});
  } catch(e){ res.status(500).json({success:false,message:e.message}); }
});

// POST create
router.post('/', async (req,res) => {
  try {
    const {name,email,department,designation,specialization,availableSlots,isAvailable} = req.body;
    if(!name||!email||!department)
      return res.status(400).json({success:false,message:'name, email, department required'});
    const [r] = await db.query(
      `INSERT INTO supervisors (name,email,department,designation,specialization,available_slots,is_available)
       VALUES (?,?,?,?,?,?,?)`,
      [name,email,department,designation||'',toStr(specialization),availableSlots||0,isAvailable!==false?1:0]
    );
    res.status(201).json({success:true,message:'Supervisor added',data:{id:r.insertId}});
  } catch(e){
    if(e.code==='ER_DUP_ENTRY') return res.status(409).json({success:false,message:'Email already exists'});
    res.status(500).json({success:false,message:e.message});
  }
});

// PUT update
router.put('/:id', async (req,res) => {
  try {
    const [check] = await db.query('SELECT id FROM supervisors WHERE id=?',[req.params.id]);
    if(!check.length) return res.status(404).json({success:false,message:'Supervisor not found'});
    const {name,email,department,designation,specialization,availableSlots,isAvailable} = req.body;
    await db.query(
      `UPDATE supervisors SET name=?,email=?,department=?,designation=?,specialization=?,
       available_slots=?,is_available=? WHERE id=?`,
      [name,email,department,designation||'',toStr(specialization),
       availableSlots||0,isAvailable!==false?1:0,req.params.id]
    );
    res.json({success:true,message:'Supervisor updated successfully'});
  } catch(e){ res.status(500).json({success:false,message:e.message}); }
});

// DELETE
router.delete('/:id', async (req,res) => {
  try {
    const [check] = await db.query('SELECT id FROM supervisors WHERE id=?',[req.params.id]);
    if(!check.length) return res.status(404).json({success:false,message:'Supervisor not found'});
    await db.query('DELETE FROM supervisors WHERE id=?',[req.params.id]);
    res.json({success:true,message:'Supervisor deleted successfully'});
  } catch(e){ res.status(500).json({success:false,message:e.message}); }
});

module.exports = router;
