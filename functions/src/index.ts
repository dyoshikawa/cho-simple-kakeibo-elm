import * as functions from 'firebase-functions'
import * as admin from 'firebase-admin'
import moment from 'moment'

// // Start writing Firebase Functions
// // https://firebase.google.com/docs/functions/typescript
//
export const helloWorld = functions.https.onRequest((request, response) => {
  const db = admin.firestore()
  request.body.db.collection('items').add({
    price: Number(request.body.price),
    userUid: request.body.uid,
    createdAt: moment().format('YYYY/MM/DD HH:mm:ss'),
  })
  response.send('Hello from Firebase!')
})
