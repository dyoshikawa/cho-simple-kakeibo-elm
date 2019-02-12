import { Elm } from './Main.elm'
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

const app = Elm.Main.init({
  node: document.getElementById('root'),
})

// firebase
//   .firestore()
//   .ref('count')
//   .on('value', snap => {
//     const count = snap.val()
//     app.ports.load.send(count)
//     console.log(`load the counter: ${count}`)
//   })

app.ports.login.subscribe(text => {
  console.log('login')
  firebase.auth().signInWithRedirect(new firebase.auth.GoogleAuthProvider())
})

app.ports.store.subscribe(count => {
  firebase
    .firestore()
    .collection('items')
    .add({
      price: 100,
      userUid: 'uid',
      createdAt: 'test',
    })
  console.log(`store the counter: ${count}`)
})

//ElmからJSへはsubscribe
// app.ports.hello.subscribe(function(fromElm) {
//   console.log(fromElm)
//   //JSからElmへはsend
//   app.ports.jsHello.send('Hi!')
// })

// //JSからElmへsend
// app.ports.jsHello.send('Elm! hellooooo')
