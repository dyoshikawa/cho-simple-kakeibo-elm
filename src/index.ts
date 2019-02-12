import firebase from 'firebase'
import 'bulma'
import '@fortawesome/fontawesome'
import '@fortawesome/fontawesome-free-solid'
import '@fortawesome/fontawesome-free-regular'
import '@fortawesome/fontawesome-free-brands'

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

app.ports.auth.subscribe(() => {
  firebase.auth().onAuthStateChanged(function(user) {
    if (user) {
      console.log(user)
      app.ports.jsGotUid.send(user.uid)
    } else {
      console.log('You are guest.')
    }
  })
})

app.ports.putSpend.subscribe(async (value: { uid: string; spend: string }) => {
  console.log('putSpend')
  console.log(value)
  await firebase
    .firestore()
    .collection('items')
    .add({
      price: value.spend,
      userUid: value.uid,
      createdAt: 'test',
    })
  const el = document.querySelector('#spendInput') as HTMLInputElement
  el.value = ''
  app.ports.jsCompletedPutSpend.send(null)
})
