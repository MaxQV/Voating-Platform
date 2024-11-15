// SPDX-License-Identifier: MIT
pragma solidity ^0.8.27;

import {Test, console} from "forge-std/Test.sol";
import "../RemixIDE/contracts/testVoting.sol";

contract VotingTest is Test {
    Voting public voting;
    address[] public newVoters;
    

    address owner = address(0x123);
    address user1 = address(0x456);
    address user2 = address(0x789);
    address user3 = address(0x142);
    address user4 = address(0x214);
    address userWinner = address(0x716);

    function setUp() public {
        vm.startPrank(owner);
        voting = new Voting();
        vm.deal(owner, 1 ether);
        vm.deal(user1, 10 ether);
        vm.deal(user2, 10 ether);
        vm.deal(user3, 10 ether);
        vm.deal(user4, 10 ether);
        vm.deal(userWinner, 1 ether);
        vm.stopPrank();
    }

    function testCreateVoting() public {
        vm.startPrank(owner);
        newVoters.push(address(0x865));
        newVoters.push(address(0x8954));
        newVoters.push(userWinner);
        newVoters.push(address(0x3827));

        voting.createVoting(newVoters, "First voting", 1);
    
        assertEq(voting.votingIndex(), 1);
        vm.stopPrank();
    }


    function testVoteForCandidate() public {
        testCreateVoting();
        vm.startPrank(user1);
        voting.voteForCandidate{value: 1 ether}(0, address(0x8954));
        voting.voteForCandidate{value: 3 ether}(0, address(0x865));
        voting.voteForCandidate{value: 5 ether}(0, address(userWinner));
        vm.stopPrank();

        vm.startPrank(user2);
        voting.voteForCandidate{value: 3 ether}(0, address(0x3827));
        voting.voteForCandidate{value: 1 ether}(0, address(0x8954));
        voting.voteForCandidate{value: 6 ether}(0, address(userWinner));
        vm.stopPrank();

        vm.startPrank(user3);
        voting.voteForCandidate{value: 3 ether}(0, address(0x3827));
        voting.voteForCandidate{value: 2 ether}(0, address(0x8954));
        voting.voteForCandidate{value: 4 ether}(0, address(userWinner));
        vm.stopPrank();

         (Voting.Candidate[] memory candidates, string memory description, uint endAt) = voting.getInfo(0);

        // Логируем данные по отдельности
        // console.log("Description - ", description);
        // console.log("End At - ", endAt);

        // // Логируем данные кандидатов отдельно
        // for (uint i = 0; i < candidates.length; i++) {
        //     console.log("Candidate Address - ", candidates[i].candidateAddress);
        //     console.log("Candidate Votes - ", candidates[i].votes);
            
        // }

    }

    function testWinnerWithdraw() public {
        testVoteForCandidate();
        (Voting.Candidate[] memory candidates, string memory description, uint endAt) = voting.getInfo(0);
        uint Difference = candidates[2].votes;
        uint BalanceBefore = userWinner.balance;

        vm.startPrank(userWinner);
        voting.winnerWithdraw(0);
        uint plFee = voting.getVotingDetails(0).platformFee;

        uint BalanceAfter = userWinner.balance;
        // console.log(BalanceBefore);
        assertEq(BalanceBefore + Difference - plFee, BalanceAfter);
        vm.stopPrank();
    }

    function testWinFailWithdraw() public {
        testVoteForCandidate();
        (Voting.Candidate[] memory candidates, string memory description, uint endAt) = voting.getInfo(0);
        uint Difference = candidates[2].votes;
        uint BalanceBefore = userWinner.balance;

        vm.startPrank(userWinner);
        voting.winnerWithdraw(0);
        uint plFee = voting.getVotingDetails(0).platformFee;

        uint BalanceAfter = userWinner.balance;
        // console.log(BalanceBefore);
        assertEq(BalanceBefore + Difference - plFee, BalanceAfter);
        vm.expectRevert("You already withdrawed!");
        voting.winnerWithdraw(0);
        vm.stopPrank();
    }





}
