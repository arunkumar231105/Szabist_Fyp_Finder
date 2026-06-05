const express = require('express');
const router  = express.Router();
const db      = require('../config/db');

const toArr = (s) => s ? s.split(',').map(x=>x.trim()).filter(Boolean) : [];
const toStr = (a) => Array.isArray(a) ? a.join(',') : (a||'');

const fmt = (r) => ({
  id: r.id, name: r.name, email: r.email,
  registrationId: r.registration_id, department: r.department,
  section: r.section, batch: r.batch,
  skills: toArr(r.skills), technologies: toArr(r.technologies),
  interests: toArr(r.interests), bio: r.bio,
  githubUrl: r.github_url, linkedinUrl: r.linkedin_url,
  completionPercentage: r.completion_percentage,
  isLocked: r.is_locked===1, isProfilePublic: r.is_profile_public===1,
  createdAt: r.created_at,
});

// GET all
router.get('/', async (req,res) => {
  try {
    const [rows] = await db.query('SELECT * FROM students ORDER BY created_at DESC');
    res.json({ success:true, count:rows.length, data:rows.map(fmt) });
  } catch(e){ res.status(500).json({success:false,message:e.message}); }
});

// GET one
router.get('/:id', async (req,res) => {
  try {
    const [rows] = await db.query('SELECT * FROM students WHERE id=?',[req.params.id]);
    if(!rows.length) return res.status(404).json({success:false,message:'Student not found'});
    res.json({ success:true, data:fmt(rows[0]) });
  } catch(e){ res.status(500).json({success:false,message:e.message}); }
});

// POST create
router.post('/', async (req,res) => {
  try {
    const {name,email,registrationId,department,section,batch,
           skills,technologies,interests,bio,githubUrl,linkedinUrl,
           completionPercentage,isLocked,isProfilePublic} = req.body;
    if(!name||!email||!registrationId||!department)
      return res.status(400).json({success:false,message:'name, email, registrationId, department required'});
    if(!email.endsWith('@szabist.pk'))
      return res.status(400).json({success:false,message:'Only @szabist.pk emails allowed'});
    const [r] = await db.query(
      `INSERT INTO students (name,email,registration_id,department,section,batch,
       skills,technologies,interests,bio,github_url,linkedin_url,
       completion_percentage,is_locked,is_profile_public) VALUES (?,?,?,?,?,?,?,?,?,?,?,?,?,?,?)`,
      [name,email,registrationId,department,section||'',batch||'',
       toStr(skills),toStr(technologies),toStr(interests),
       bio||null,githubUrl||null,linkedinUrl||null,
       completionPercentage||0,isLocked?1:0,isProfilePublic!==false?1:0]
    );
    res.status(201).json({success:true,message:'Student created',data:{id:r.insertId}});
  } catch(e){
    if(e.code==='ER_DUP_ENTRY') return res.status(409).json({success:false,message:'Email or Registration ID already exists'});
    res.status(500).json({success:false,message:e.message});
  }
});

// PUT update
router.put('/:id', async (req,res) => {
  try {
    const [check] = await db.query('SELECT id FROM students WHERE id=?',[req.params.id]);
    if(!check.length) return res.status(404).json({success:false,message:'Student not found'});
    const {name,email,registrationId,department,section,batch,
           skills,technologies,interests,bio,githubUrl,linkedinUrl,
           completionPercentage,isLocked,isProfilePublic} = req.body;
    await db.query(
      `UPDATE students SET name=?,email=?,registration_id=?,department=?,section=?,batch=?,
       skills=?,technologies=?,interests=?,bio=?,github_url=?,linkedin_url=?,
       completion_percentage=?,is_locked=?,is_profile_public=? WHERE id=?`,
      [name,email,registrationId,department,section||'',batch||'',
       toStr(skills),toStr(technologies),toStr(interests),
       bio||null,githubUrl||null,linkedinUrl||null,
       completionPercentage||0,isLocked?1:0,isProfilePublic!==false?1:0,
       req.params.id]
    );
    res.json({success:true,message:'Student updated successfully'});
  } catch(e){ res.status(500).json({success:false,message:e.message}); }
});

// DELETE
router.delete('/:id', async (req,res) => {
  try {
    const [check] = await db.query('SELECT id FROM students WHERE id=?',[req.params.id]);
    if(!check.length) return res.status(404).json({success:false,message:'Student not found'});
    await db.query('DELETE FROM students WHERE id=?',[req.params.id]);
    res.json({success:true,message:'Student deleted successfully'});
  } catch(e){ res.status(500).json({success:false,message:e.message}); }
});

module.exports = router;
