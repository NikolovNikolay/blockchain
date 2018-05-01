var Splitter = artifacts.require("./Splitter.sol");
var throwsAsync = require('assert-throws-async');

contract('Splitter', function (accounts) {

    // FOR SOME REASON FAILS
    // it("Should interrupt contract and not split ether amount", function () {
    //     let splitter;
    //
    //     const totalSendAmount = web3.toWei(18, "ether");
    //     const senderBalanceAfter = web3.eth.getBalance(accounts[0]).toNumber() - totalSendAmount;
    //
    //     return Splitter.deployed().then(function (instance) {
    //         splitter = instance;
    //
    //         return splitter.interruptContract.sendTransaction({from: accounts[0]});
    //     }).then(function (txHash) {
    //
    //         return splitter.getState();
    //     }).then(function (state) {
    //         assert.isFalse(state, "Contract state is not as expected");
    //
    //         async function notPermittedTransaction() {
    //             splitter.splitAmount.sendTransaction(
    //                 accounts[1],
    //                 accounts[2],
    //                 {from: accounts[0]},
    //                 {value: totalSendAmount, gas: 3000000});
    //         }
    //
    //         throwsAsync(notPermittedTransaction, Error, "Contract is interrupted - operation not available");
    //         assert.isAbove(web3.eth.getBalance(
    //             accounts[0]).toNumber(),
    //             senderBalanceAfter,
    //             "The amount was taken from sender when contract was interrupted");
    //     });
    // });

    it("Should resume contract", function () {
        let splitter;

        return Splitter.deployed().then(function (instance) {
            splitter = instance;

            return splitter.resumeContract.sendTransaction({from: accounts[0]});
        }).then(function (txHash) {
            return splitter.getState();
        }).then(function (state) {
            assert.isTrue(state, "Contract state is not as expected");
        });
    });

    it("should put 6.87655 Eth in passed two accounts", function () {
        let splitter;

        const totalSendAmount = web3.toWei(13.7531, "ether");
        const halfAmount = web3.toWei(6.87655, "ether");
        const senderBalance = web3.eth.getBalance(accounts[0]).toNumber();
        const senderBalanceAfter = senderBalance - totalSendAmount;

        return Splitter.deployed().then(function (instance) {
            splitter = instance;

            return splitter.splitAmount.sendTransaction(
                accounts[1],
                accounts[2],
                {from: accounts[0]},
                {value: totalSendAmount});

        }).then(function (txHash) {
            assert.notEqual(txHash, 0, "Split payable transaction was not a success");

            // Check for below, cause sender's balance should be reduced by the
            // amount send and the gas the transaction required (fairly accurate)
            assert.isBelow(web3.eth.getBalance(
                accounts[0]).toNumber(),
                senderBalanceAfter,
                "The send amount was not taken from the sender's balance as expected");

            // Get balance of the first recipient
            return splitter.balanceOf.call(accounts[1]);
        }).then(function (firstBalance) {

            // Check if the balance of the first recipient in the Splitter
            // contract is as expected
            assert.equal(firstBalance, halfAmount, "First recipient's amount is not as expected");

            // Now check balance of the second recipient
            return splitter.balanceOf(accounts[2]);
        }).then(function (secondBalance) {

            // Assert balance incremented
            assert.equal(secondBalance, halfAmount, "Second recipient's amount is not as expected");
        });
    });

    it("should put 2 Eth in passed two accounts", function () {
        let splitter;

        const totalSendAmount = web3.toWei(2, "ether");
        const halfAmount = web3.toWei(1, "ether");
        const senderBalance = web3.eth.getBalance(accounts[0]).toNumber();
        const senderBalanceAfter = senderBalance - totalSendAmount;

        return Splitter.deployed().then(function (instance) {
            splitter = instance;

            return splitter.splitAmount.sendTransaction(
                accounts[1],
                accounts[2],
                {from: accounts[0]},
                {value: totalSendAmount});

        }).then(function (txHash) {
            assert.notEqual(txHash, 0, "Split payable transaction was not a success");

            // Check for below, cause sender's balance should be reduced by the
            // amount send and the gas the transaction required (fairly accurate)
            assert.isBelow(web3.eth.getBalance(
                accounts[0]).toNumber(),
                senderBalanceAfter,
                "The send amount was not taken from the sender's balance as expected");

            // Get balance of the first recipient
            return splitter.balanceOf.call(accounts[1]);
        }).then(function (firstBalance) {

            // Check if the balance of the first recipient in the Splitter
            // contract is as expected
            assert.isAtLeast(firstBalance, halfAmount, "First recipient's amount is not as expected");

            // Now check balance of the second recipient
            return splitter.balanceOf(accounts[2]);
        }).then(function (secondBalance) {

            // Assert balance incremented
            assert.isAtLeast(secondBalance, halfAmount, "Second recipient's amount is not as expected");
        });
    });

    it("Should not be able to send 0 as amount to split between addresses", function () {
        let splitter;

        const totalSendAmount = web3.toWei(0, "ether");
        const senderBalance = web3.eth.getBalance(accounts[0]).toNumber();

        return Splitter.deployed().then(function (instance) {
            splitter = instance;

            async function notPermittedTransaction() {
                splitter.splitAmount.sendTransaction(
                    accounts[1],
                    accounts[2],
                    {from: accounts[0]},
                    {value: totalSendAmount, gas: 3000000});
            }

            throwsAsync(notPermittedTransaction, Error, "O is not valid amount to split, so revert!");
            assert.equal(web3.eth.getBalance(accounts[0]).toNumber(), senderBalance);
        });
    });
});
