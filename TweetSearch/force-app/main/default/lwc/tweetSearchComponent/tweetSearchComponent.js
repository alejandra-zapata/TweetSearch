import { LightningElement } from 'lwc';
import getTweet from '@salesforce/apex/TweetSearchComponentController.getTweet';

export default class TweetSearchComponent extends LightningElement {
    searchData;
    twitterText;
    createdAt;
    authorId;
    errorMsg = '';
    strTweetId = '';

    handleTweetId(event) {
        this.strTweetId = event.detail.value;
    }

    handleTweetSearch() {
        this.searchData = undefined;
        this.errorMsg = '';
        if(!this.strTweetId) {
            this.errorMsg = 'Please enter a tweet id to search.';
            return;
        }

        getTweet({ tid : this.strTweetId })
        .then(result => {
            if(result == undefined){
                this.errorMsg = 'Sorry, we couldn\'t find the tweet you\'re looking for.';
                return;
            }
            this.searchData = result[0];
            this.twitterText = this.searchData['text'];
            this.createdAt = this.searchData['created_at'];
            this.authorId = this.searchData['author_id'];
            this.errorMsg = '';
        })
        .catch(error => { 
            this.searchData = undefined;
            if(error) {
                this.errorMsg = error.body.message;
            }
        })
    }
}