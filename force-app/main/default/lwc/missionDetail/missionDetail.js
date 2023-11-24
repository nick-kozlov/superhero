import { LightningElement, api, track, wire } from 'lwc';
import { subscribe, MessageContext          } from 'lightning/messageService';
import { ShowToastEvent                     } from 'lightning/platformShowToastEvent'
import MISSION_SELECTED_CHANNEL  from '@salesforce/messageChannel/Mission_Selected__c';
import getHeroMissionAssignments from '@salesforce/apex/MissionDetailController.getHeroMissionAssignments';
import createMissionAssignment   from '@salesforce/apex/MissionDetailController.createMissionAssignment';
import completeMission           from '@salesforce/apex/MissionDetailController.completeMission';

export default class MissionDetail extends LightningElement {
    @wire(MessageContext)
    messageContext;

    @api placeholder;

    subscription = null;
    recordId;
    mission;
    isMissionSelected = false;
    heroWrapper;
    hasAssignment;

    title = 'Mission Details';
    tooHighRankMessage = 'К сожалению вы слишком слабый на данный момент чтобы взяться за эту работку! Возвращайтесь когда достигните ранга ';
    ranksToIndexMap = new Map([
        ["D", 1],
        ["C", 2],
        ["B", 3],
        ["A", 4],
        ["S", 5]
    ]);

    subscribeToMessageChannel() {
        this.subscription = subscribe(
            this.messageContext,
            MISSION_SELECTED_CHANNEL,
            (message) => this.handleMessage(message)
        );
    }

    handleMessage(message) {
        this.recordId = message.recordId;
        this.mission = message.recordData.value;
        this.hasAssignment = this.heroWrapper.missionAssignments.some(item => item.Mission__c == this.mission.Id);
        this.isMissionSelected = true;
    }

    handleAcceptMission() {
        if (this.heroWrapper.numberOfActiveMissions >= 3) {
            this.showToast(
                'warning',
                'Вы можете принять только 3 активных миссии одновременно.'
            );
        } else {
            if (this.isHeroRankAppropriate()){
                createMissionAssignment({
                    heroId: this.heroWrapper.heroId,
                    missionId: this.mission.Id
                })
                .then(result => {
                    this.doInit();
                    this.showToast(
                        'success',
                        'Миссия принята!'
                    );
                    eval("$A.get('e.force:refreshView').fire();");
                }).catch(error => {
                    this.showToast('error', error.body.message);
                });
            } else {
                this.showToast(
                    'warning',
                    this.tooHighRankMessage + '"' + this.getKeyByValue(this.ranksToIndexMap, this.ranksToIndexMap.get(this.mission.Complexity_Rank__c) - 1) + '"'
                );
            }
        }
    }

    handleCompleteMission() {
        let missionAssignmentId = this.heroWrapper.missionAssignments.find(item => item.Mission__c == this.mission.Id).Id;

        completeMission({
            missionAssignmentId: missionAssignmentId
        })
        .then(result => {
            this.doInit();
            this.showToast(
                'success',
                'Миссия выполнена!'
            );
            window.location.reload();
        }).catch(error => {
            this.showToast('error', error.body.message);
        });
    }

    get isMissionInProgress() {
        return this.hasAssignment && this.mission.Status__c != 'Completed';
    }

    get isMissionAvailable() {
        return !this.hasAssignment && this.mission.Status__c != 'Completed';
    }

    connectedCallback() {
        this.subscribeToMessageChannel();
        this.doInit();
    }

    doInit() {
        getHeroMissionAssignments()
        .then(result => {
            this.heroWrapper = JSON.parse(result);
        }).catch(error => {
            this.showToast('error', error.body.message);
        });
    }

    showToast(type, message) {
        const event = new ShowToastEvent({
            variant: type,
            message: message
        });
        this.dispatchEvent(event);
    }

    isHeroRankAppropriate(){
        let heroRankNumber = this.ranksToIndexMap.get(this.heroWrapper.rank);
        let missionRankNumber = this.ranksToIndexMap.get(this.mission.Complexity_Rank__c);
        return heroRankNumber >= missionRankNumber - 1;

    }

    getKeyByValue(map, searchValue) {
        for (let [key, value] of map.entries()) {
            if (value === searchValue)
                return key;
        }
    }
}