import firebase from 'firebase/app'
import 'firebase/auth'
import 'firebase/firestore'
import moment from 'moment'

import 'bulma'
import 'bulma-pageloader'
import 'material-icons/iconfont/material-icons.scss'

const config = {
  apiKey: 'AIzaSyBsJBMFYIR_kN9dC1rdoLhRz41Xehe3aUo',
  authDomain: 'cho-simple-kakeibo-develop.firebaseapp.com',
  databaseURL: 'https://cho-simple-kakeibo-develop.firebaseio.com',
  projectId: 'cho-simple-kakeibo-develop',
  storageBucket: 'cho-simple-kakeibo-develop.appspot.com',
  messagingSenderId: '829229852981',
}
firebase.initializeApp(config)

const elm: any = require('./Main.elm')

const app = elm.Elm.Main.init({
  node: document.getElementById('root'),
})

app.ports.login.subscribe(() => {
  console.log('login')
  firebase.auth().signInWithRedirect(new firebase.auth.GoogleAuthProvider())
})

app.ports.logout.subscribe(() => {
  console.log('logout')
  firebase.auth().signOut()
})

app.ports.auth.subscribe(() => {
  firebase.auth().onAuthStateChanged(async user => {
    if (user) {
      console.log(user)
      const idToken = await user.getIdToken()
      console.log(idToken)
      app.ports.fetchedMe.send({ uid: user.uid, idToken: idToken })
    } else {
      app.ports.checkedAuth.send(null)
      console.log('You are guest.')
    }
  })
})

app.ports.fetchSpendItems.subscribe(async (uid: string) => {
  console.log('fetchItems')
  const userDocRef = await firebase
    .firestore()
    .collection('users')
    .doc(uid)
  await firebase
    .firestore()
    .collection('items')
    .where('userId', '==', userDocRef)
    .onSnapshot(snapShot => {
      const items: {
        id: string
        price: number
        createdAt: string
        busy: boolean
      }[] = snapShot.docs.map(doc => ({
        id: doc.id,
        price: doc.data().price as number,
        createdAt: moment(doc.data().createdAt.toDate()).format(
          'YY/MM/DD HH:mm:ss'
        ),
        busy: false,
      }))
      items.sort((a, b) => {
        if (a.createdAt > b.createdAt) return -1
        if (a.createdAt < b.createdAt) return 1
        return 0
      })
      console.log(items)
      app.ports.fetchedSpendItems.send(items)
    })
})

app.ports.resetSpendInputValue.subscribe(async () => {
  console.log('putSpendInputValue')
  const el = document.querySelector('#spendInput') as HTMLInputElement
  el.value = ''
})

app.ports.putSpendItem.subscribe(async (uid: string, price: number) => {
  console.log('putSpendItem')
  const db = firebase.firestore()
  const userDocRef = await db.collection('users').doc(uid)
  await db
    .collection('items')
    .add({
      price: Number(price),
      userId: userDocRef,
      createdAt: new Date(),
    })
    .catch(error => {
      console.error(error)
    })
})

app.ports.deleteSpendItem.subscribe(async (id: string) => {
  console.log('deleteSpendItem')
  const db = firebase.firestore()
  await db
    .collection('items')
    .doc(id)
    .delete()
    .catch(function(error) {
      console.error('Error removing document: ', error)
    })
})
