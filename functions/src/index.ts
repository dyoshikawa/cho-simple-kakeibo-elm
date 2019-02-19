import * as functions from 'firebase-functions'
import * as admin from 'firebase-admin'
import express, * as Express from 'express'
import cors from 'cors'
import { user } from 'firebase-functions/lib/providers/auth'

admin.initializeApp()

const spendItemsApp = express()

const authenticate = async (
  req: any,
  res: Express.Response,
  next: Express.NextFunction
) => {
  const authorization = req.get('Authorization')
  if (authorization == null) {
    res.status(401).send({ errors: ['Unauthenticated.'] })
    return
  }

  const idToken = authorization.split('Bearer ')[1]

  console.log(`idToken: ${idToken}`)

  const me = await admin
    .auth()
    .verifyIdToken(idToken)
    .catch(error => {
      console.error(error)
      res.status(401).send({ errors: ['Unauthenticated.'] })
    })
  if (me == null) {
    return res.status(401).send({ errors: ['Unauthenticated.'] })
  }

  req.me = me

  next()
}
spendItemsApp.use([
  cors({
    origin: true,
    methods: ['GET', 'PUT', 'POST', 'DELETE'],
    allowedHeaders: ['Content-Type', 'Authorization'],
  }),
  authenticate,
])

spendItemsApp.post(
  '/',
  async (req: any, res): Promise<Express.Response> => {
    console.log('Started post spend items.')

    const me = req.me

    console.log(`me: ${me}`)

    const price = req.body.price

    console.log(`price: ${price}`)

    const db = admin.firestore()
    const userDocRef = await db.collection('users').doc(me.uid)
    await db
      .collection('items')
      .add({
        price: Number(price),
        userId: userDocRef,
        createdAt: new Date(),
      })
      .catch(error => {
        console.error(error)
        return res.status(500).send({ errors: ['Failed to put data.'] })
      })

    return res.status(200).send({ message: 'Success.' })
  }
)

spendItemsApp.delete(
  '/:id',
  async (req: any, res): Promise<Express.Response> => {
    const me = req.me

    console.log(`me: ${me}`)

    console.log(`req.params.id: ${req.params.id}`)

    const db = admin.firestore()
    const docRef = db.collection('items').doc(req.params.id)
    const userDocRef = db.collection('users').doc(me.uid)

    const doc = await docRef.get()
    console.log(`doc ${doc.id}`)
    if (!doc.exists) return res.status(422).send('Invalid doc id.')
    const data = doc.data()
    if (data == null) return res.status(422).send('Invalid doc id.')
    console.log(`data: ${data.userId}`)
    if (!userDocRef.isEqual(data.userId))
      return res.status(401).send('Unauthenticated.')

    await db
      .collection('items')
      .doc(doc.id)
      .delete()
      .catch(function(error) {
        console.error('Error removing document: ', error)
        return res.status(500).send({ errors: ['Fail to delete document.'] })
      })

    return res.status(200).send({ id: doc.id })
  }
)

exports.spendItems = functions.https.onRequest(spendItemsApp)

exports.createUserDocument = functions.auth.user().onCreate(async user => {
  const db = admin.firestore()
  await db
    .collection('users')
    .doc(user.uid)
    .set({
      budgetPrice: 0,
      createdAt: new Date(),
    })
    .catch(error => {
      console.error(error)
    })
})
