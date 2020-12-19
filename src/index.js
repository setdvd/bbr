import './main.css';
import { Elm } from './Main.elm';
import * as serviceWorker from './serviceWorker';

const urlParams = new URLSearchParams(window.location.search);
const version = urlParams.get('v');

const CRED_KEY = "CRED"

const cred = JSON.parse(localStorage.getItem(CRED_KEY) || "{}")

const app = Elm.Main.init({
  node: document.getElementById('root'),
  flags:{
    version,
    cred
  },
});

app.ports.notification.subscribe(({status})=>{
  if('Notification' in window){
    new window.Notification(`Build status changed to ${status}`)
  }
})

app.ports.saveCred.subscribe((cred)=>{
  localStorage.setItem(CRED_KEY, JSON.stringify(cred))
})

// If you want your app to work offline and load faster, you can change
// unregister() to register() below. Note this comes with some pitfalls.
// Learn more about service workers: https://bit.ly/CRA-PWA
serviceWorker.unregister();
