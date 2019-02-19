import firebase from 'firebase/app'
import 'firebase/auth'
import 'firebase/firestore'
import { Chart } from 'chart.js'
import 'bulma'
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

app.ports.auth.subscribe(() => {
  firebase.auth().onAuthStateChanged(async user => {
    if (user) {
      console.log(user)
      const idToken = await user.getIdToken()
      console.log(idToken)
      app.ports.fetchedMe.send({ uid: user.uid, idToken: idToken })
    } else {
      console.log('You are guest.')
    }
  })
})

app.ports.fetchSpendItems.subscribe((uid: string) => {
  console.log('fetchItems')
  firebase
    .firestore()
    .collection('items')
    .where('userUid', '==', uid)
    .onSnapshot(snapShot => {
      const items: {
        price: number
        userUid: string
        createdAt: string
      }[] = snapShot.docs.map(doc => ({
        id: doc.id,
        price: doc.data().price as number,
        userUid: doc.data().userUid as string,
        createdAt: doc.data().createdAt as string,
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

app.ports.generateBudgetChart.subscribe(() => {
  const el = document.getElementById('myChart') as HTMLCanvasElement
  const ctx = el.getContext('2d')
  if (ctx == null) {
    return
  }

  const chart = new Chart(ctx, {
    // The type of chart we want to create
    type: 'line',

    // The data for our dataset
    data: {
      labels: ['January', 'February', 'March', 'April', 'May', 'June', 'July'],
      datasets: [
        {
          label: 'My First dataset',
          backgroundColor: 'rgb(255, 99, 132)',
          borderColor: 'rgb(255, 99, 132)',
          data: [0, 10, 5, 2, 20, 30, 45],
        },
      ],
    },

    // Configuration options go here
    options: {},
  })
})
