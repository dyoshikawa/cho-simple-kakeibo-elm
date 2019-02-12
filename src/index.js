import { Elm } from './Main.elm'
import 'bulma'

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

firebase.firestore()

firebase
  .database()
  .ref('count')
  .on('value', snap => {
    const count = snap.val()
    app.ports.load.send(count)
    console.log(`load the counter: ${count}`)
  })

app.ports.store.subscribe(count => {
  firebase
    .database()
    .ref('count')
    .set(count)
  console.log(`store the counter: ${count}`)
})
