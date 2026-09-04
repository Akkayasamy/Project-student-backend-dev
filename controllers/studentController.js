const pool = require('../config/db');

// GET /api/students
exports.getStudents = async (req, res) => {
  try {
    const search = req.query.search ? `%${req.query.search}%` : null;
    let query = 'SELECT * FROM students WHERE user_id = ?';
    const params = [req.user.id];

    if (search) {
      query += ' AND (first_name LIKE ? OR last_name LIKE ? OR email LIKE ? OR course LIKE ?)';
      params.push(search, search, search, search);
    }
    query += ' ORDER BY created_at DESC';

    const [rows] = await pool.query(query, params);
    return res.json({ students: rows });
  } catch (err) {
    console.error('Get students error:', err);
    return res.status(500).json({ message: 'Server error fetching students.' });
  }
};

// GET /api/students/:id
exports.getStudent = async (req, res) => {
  try {
    const [rows] = await pool.query(
      'SELECT * FROM students WHERE id = ? AND user_id = ?',
      [req.params.id, req.user.id]
    );
    if (rows.length === 0) return res.status(404).json({ message: 'Student not found.' });
    return res.json({ student: rows[0] });
  } catch (err) {
    console.error('Get student error:', err);
    return res.status(500).json({ message: 'Server error fetching student.' });
  }
};

// POST /api/students
exports.createStudent = async (req, res) => {
  try {
    const { first_name, last_name, email, phone, course, enrollment_date } = req.body;

    if (!first_name || !last_name || !email) {
      return res.status(400).json({ message: 'First name, last name and email are required.' });
    }

    const [result] = await pool.query(
      `INSERT INTO students (user_id, first_name, last_name, email, phone, course, enrollment_date)
       VALUES (?, ?, ?, ?, ?, ?, ?)`,
      [req.user.id, first_name, last_name, email, phone || null, course || null, enrollment_date || null]
    );

    const [rows] = await pool.query('SELECT * FROM students WHERE id = ?', [result.insertId]);
    return res.status(201).json({ message: 'Student created.', student: rows[0] });
  } catch (err) {
    console.error('Create student error:', err);
    return res.status(500).json({ message: 'Server error creating student.' });
  }
};

// PUT /api/students/:id
exports.updateStudent = async (req, res) => {
  try {
    const { first_name, last_name, email, phone, course, enrollment_date } = req.body;

    const [existing] = await pool.query(
      'SELECT id FROM students WHERE id = ? AND user_id = ?',
      [req.params.id, req.user.id]
    );
    if (existing.length === 0) return res.status(404).json({ message: 'Student not found.' });

    await pool.query(
      `UPDATE students SET first_name=?, last_name=?, email=?, phone=?, course=?, enrollment_date=?
       WHERE id=? AND user_id=?`,
      [first_name, last_name, email, phone || null, course || null, enrollment_date || null, req.params.id, req.user.id]
    );

    const [rows] = await pool.query('SELECT * FROM students WHERE id = ?', [req.params.id]);
    return res.json({ message: 'Student updated.', student: rows[0] });
  } catch (err) {
    console.error('Update student error:', err);
    return res.status(500).json({ message: 'Server error updating student.' });
  }
};

// DELETE /api/students/:id
exports.deleteStudent = async (req, res) => {
  try {
    const [result] = await pool.query(
      'DELETE FROM students WHERE id = ? AND user_id = ?',
      [req.params.id, req.user.id]
    );
    if (result.affectedRows === 0) return res.status(404).json({ message: 'Student not found.' });
    return res.json({ message: 'Student deleted.' });
  } catch (err) {
    console.error('Delete student error:', err);
    return res.status(500).json({ message: 'Server error deleting student.' });
  }
};
