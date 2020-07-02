const functions = require('firebase-functions');
const algoliasearch = require('algoliasearch');

const APP_ID = functions.config().algolia.app;

const client = algoliasearch(functions.config().algolia.appid, functions.config().algolia.apikey);
const index  = client.initIndex('decks');

exports.addToIndex = functions.firestore.document('decks/{deckId}')

    .onCreate(snapshot => {
        const data = snapshot.data();
        const objectID = snapshot.id;
        console.log(data);
        return index.addObject({...data, objectID});
    });

exports.updateIndex = functions.firestore.document('decks/{deckId}')

    .onUpdate((change) => {
        const newData = change.after.data();
        const objectID = change.after.id;

        return index.saveObject({ ...newData, objectID});
    });

exports.deleteFromIndex = functions.firestore.document('decks/{deckId}')

    .onDelete(snapshot => index.deleteObject(snapshot.id));