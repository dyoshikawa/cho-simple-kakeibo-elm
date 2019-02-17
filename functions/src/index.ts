import * as functions from 'firebase-functions'
import * as admin from 'firebase-admin'
import moment from 'moment'
import express, * as Express from 'express'
import cors from 'cors'

admin.initializeApp()

const spendItemsApp = express()

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

  console.log(`idToken: ${idToken}`)

  const me = await admin
    .auth()
    .verifyIdToken(idToken)
    .catch(error => {
      console.error(error)
      res.send('Invalid authenticated.')
    })

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

spendItemsApp.delete(
  '/:id',
  async (req: any, res): Promise<Express.Response> => {
    const me = req.me

    console.log(`me: ${me}`)
    // return res.send(me)

    if (me == null) {
      return res.send('Invalid authenticated.')
    }
    console.log(`req.params.id: ${req.params.id}`)

    const db = admin.firestore()
    const docRef = db.collection('items').doc(req.params.id)

    const doc = await docRef.get()
    if (!doc.exists) return res.send('Invalid doc id.')
    const data = doc.data()
    if (data == null) return res.send('Invalid doc id.')
    if (data.uid != me.uid) return res.send('Invalid doc id.')

    db.collection('items')
      .doc(doc.id)
      .delete()
      .then(function() {
        return res.send('Document successfully deleted!')
      })
      .catch(function(error) {
        console.error('Error removing document: ', error)
        return res.send('Fail to delete document.')
      })

    return res.send('Hello from Firebase!')
  }
)

exports.spendItems = functions.https.onRequest(spendItemsApp)
