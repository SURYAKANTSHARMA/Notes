const express = require('express')
const fs = require('fs')
const Note = require('./models/notes')
require('./db/mongoose')

const app = express()
app.use(express.json())

//Create 
app.post('/notes', async (req, res) => {
    const note = new Note(req.body)

    try {
        await note.save() 
        res.status(201).send(note)

    } catch(err){
        console.error(err); // Log the error
        res.status(500).send(err)
    }
})
// Read 
app.get('/notes', async (req, res) => {
    try {
        const notes = await Note.find({}) 
        res.send(notes)
    } catch (err) {
        console.error(err); // Log the error
        res.status(500).send(err)
    }
})

// update 
app.patch('/notes/:id', async (req, res) => {
    try {
      const note = await Note.findById(req.params.id)
      if (!note) {
        return res.status(404).send()
     }

      note.note = req.body.note
      await note.save() 
      res.status(200).send(note)
    }  catch(err) {
      console.error(err); // Log the error
      res.status(404).send(err)
  } 
  
  })

// Delete 
app.delete('/notes/:id', async (req, res) => {
  try {
    const note = await Note.findByIdAndDelete(req.params.id)
    if (!note) {
        return res.status(404).send()
    }
    res.status(200).send("note is deleted")
  }  catch(err) {
    console.error(err); // Log the error
    res.status(500).send(err)
} 
}) 

app.listen(3000, () => {
    console.log("the server is up on port 3000")
}) 

 