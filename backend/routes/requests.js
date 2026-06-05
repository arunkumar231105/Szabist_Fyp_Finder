const express = require('express');
const router  = express.Router();
const db      = require('../config/db');

// GET all (optional ?status=pending)
router.get('/', async (req,res) => {
  try {
    const {status} = req.query;
    let sql='SELECT * FROM requests', params=[];
    if(status){ sql+=' WHERE status=?'; params=[status]; }
    sql+=' ORDER BY created_at DESC';
    const [rows] = await db.query(sql,params);
    res.json({success:true,count:rows.length,data:rows});
  } catch(e){ res.status(500).json({success:false,message:e.message}); }
});

// GET one
router.get('/:id', async (req,res) => {
  try {
    const [rows] = await db.query('SELECT * FROM requests WHERE id=?',[req.params.id]);
    if(!rows.length) return res.status(404).json({success:false,message:'Request not found'});
    res.json({success:true,data:rows[0]});
  } catch(e){ res.status(500).json({success:false,message:e.message}); }
});

// POST create
router.post('/', async (req,res) => {
  try {
    const {senderName,senderDept,receiverName,message} = req.body;
    if(!senderName||!senderDept||!receiverName)
      return res.status(400).json({success:false,message:'senderName, senderDept, receiverName required'});
    const [r] = await db.query(
      'INSERT INTO requests (sender_name,sender_dept,receiver_name,message) VALUES (?,?,?,?)',
      [senderName,senderDept,receiverName,message||'']
    );
    res.status(201).json({success:true,message:'Request sent successfully',data:{id:r.insertId}});
  } catch(e){ res.status(500).json({success:false,message:e.message}); }
});

// PUT update
router.put('/:id', async (req,res) => {
  try {
    const [check] = await db.query('SELECT id FROM requests WHERE id=?',[req.params.id]);
    if(!check.length) return res.status(404).json({success:false,message:'Request not found'});
    const {senderName,senderDept,receiverName,message,status} = req.body;
    await db.query(
      'UPDATE requests SET sender_name=?,sender_dept=?,receiver_name=?,message=?,status=? WHERE id=?',
      [senderName,senderDept,receiverName,message||'',status||'pending',req.params.id]
    );
    res.json({success:true,message:'Request updated successfully'});
  } catch(e){ res.status(500).json({success:false,message:e.message}); }
});

// DELETE
router.delete('/:id', async (req,res) => {
  try {
    const [check] = await db.query('SELECT id FROM requests WHERE id=?',[req.params.id]);
    if(!check.length) return res.status(404).json({success:false,message:'Request not found'});
    await db.query('DELETE FROM requests WHERE id=?',[req.params.id]);
    res.json({success:true,message:'Request deleted successfully'});
  } catch(e){ res.status(500).json({success:false,message:e.message}); }
});

module.exports = router;
