import * as functions from 'firebase-functions'
import * as admin from 'firebase-admin'
import moment from 'moment'
import express from 'express'
import cors from 'cors'

admin.initializeApp()

const spendItemsApp = express()
spendItemsApp.use(
  cors({
    origin: true,
    methods: ['GET', 'PUT', 'POST'],
    allowedHeaders: ['Content-Type', 'Authorization'],
    credentials: true,
  })
)

spendItemsApp.get('/', async (req, res) => {
  const authorization = req.get('Authorization')
  if (authorization == null) {
    res.send({ errors: ['Invalid authenticated.'] })
    return
  }

  const idToken = authorization.split('Bearer ')[1]

  const decodedToken = await admin
    .auth()
    .verifyIdToken(idToken)
    .catch(error => {
      console.error(error)
      res.send('Invalid authenticated.')
    })
  console.log(decodedToken)
  res.send(decodedToken)

  const db = admin.firestore()
  req.body.db.collection('items').add({
    price: Number(req.body.price),
    userUid: req.body.uid,
    createdAt: moment().format('YYYY/MM/DD HH:mm:ss'),
  })

  res.header('Access-Control-Allow-Origin', '*')
  res.send('Hello from Firebase!')
})

exports.spendItems = functions.https.onRequest(spendItemsApp)
