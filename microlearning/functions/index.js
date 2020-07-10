const functions = require('firebase-functions');
const algoliasearch = require('algoliasearch');

const APP_ID = functions.config().algolia.app;

const client = algoliasearch(functions.config().algolia.appid, functions.config().algolia.apikey);
const index  = client.initIndex('decks');
const user_index = client.initIndex('user_data');

exports.addToIndex = functions.firestore.document('decks/{deckId}')

    .onCreate(snapshot => {
        const data = snapshot.data();
        const objectID = snapshot.id;
        // console.log(data);
        return index.saveObject({...data, objectID});
    });

exports.updateIndex = functions.firestore.document('decks/{deckId}')

    .onUpdate((change) => {
        const newData = change.after.data();
        const objectID = change.after.id;

        return index.saveObject({ ...newData, objectID});
    });

exports.deleteFromIndex = functions.firestore.document('decks/{deckId}')

    .onDelete(snapshot => index.deleteObject(snapshot.id));

// Group Search starts from here.

exports.addToUserIndex = functions.firestore.document('user_data/{userId}') //can be an error here.

    .onCreate(snapshot => {
        const data = snapshot.data();
        const objectID = snapshot.id;
        console.log(data);
        return user_index.saveObject({...data, objectID});
    });

exports.updateUserIndex = functions.firestore.document('user_data/{userId}')

    .onUpdate((change) => {
        const newData = change.after.data();
        const objectID = change.after.id;

        return user_index.saveObject({ ...newData, objectID});
    });

exports.deleteFromUserIndex = functions.firestore.document('user_data/{userId}')

    .onDelete(snapshot => user_index.deleteObject(snapshot.id));



