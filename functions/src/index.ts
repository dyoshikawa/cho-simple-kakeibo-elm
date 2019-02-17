import * as functions from 'firebase-functions'
import * as admin from 'firebase-admin'
import moment from 'moment'
import express, * as Express from 'express'
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
const authenticate = async (
  req: any,
  res: Express.Response,
  next: Express.NextFunction
) => {
  const authorization = req.get('Authorization')
  if (authorization == null) {
    res.send({ errors: ['Invalid authenticated.'] })
    return
  }

  const idToken = authorization.split('Bearer ')[1]

  const me = await admin
    .auth()
    .verifyIdToken(idToken)
    .catch(error => {
      console.error(error)
      res.send('Invalid authenticated.')
    })
  console.log(me)

  req.me = me

  next()
}
spendItemsApp.use(authenticate)

spendItemsApp.get(
  '/',
  async (req: any, res): Promise<Express.Response> => {
    const me = req.me

    console.log(me)
    // return res.send(me)

    if (me == null) {
      return res.send('Invalid authenticated.')
    }

    const db = admin.firestore()
    db.collection('items').add({
      price: Number(req.body.price),
      userUid: me.uid,
      createdAt: moment().format('YYYY/MM/DD HH:mm:ss'),
    })

    res.header('Access-Control-Allow-Origin', '*')
    return res.send('Hello from Firebase!')
  }
)

exports.spendItems = functions.https.onRequest(spendItemsApp)
