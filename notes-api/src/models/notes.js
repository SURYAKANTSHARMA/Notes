const mongoose = require('mongoose')
const Note = mongoose.model('Note', {
  note: {
    type: String
  }   
})

module.exports = Note