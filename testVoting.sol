// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract Voting {
    address owner;
    uint public votingIndex;
    uint public feeForOwner;

    constructor() {
        owner = msg.sender;
    }

    struct Candidate {
        address candidateAddress;
        uint votes;
    }

    struct VotingDetails {
        Candidate[] candidates;
        string description;
        uint endAt;
        address winner;
        uint finalVote;
        uint platformFee;
        bool winnerWithdrawed;
        
    }


    mapping (uint => VotingDetails) private votings;
    

    modifier onlyOwner() {
        require(msg.sender == owner, "you are not an owner!");
        _;
    }

    modifier isAddressInVoting(uint _votingIndex, address _votingFor) {
        bool exist;
        for (uint i = 0; i < (votings[_votingIndex].candidates).length; i++) {

            if (votings[_votingIndex].candidates[i].candidateAddress == _votingFor) {
                exist = true;
                break;
            }
        }
        require(exist == true, "address not found in voting");
        _;
    }

    function createVoting(address[] memory _newVoters, string memory _description, uint _duration) external onlyOwner {
        VotingDetails storage newVoting = votings[votingIndex];

        for (uint i = 0; i < _newVoters.length; i++) {
            newVoting.candidates.push(Candidate({
                candidateAddress: _newVoters[i],
                votes: 0
            }));
        }

        newVoting.description = _description;
        newVoting.endAt = block.timestamp + _duration;


        votingIndex++;

    }

    function voteForCandidate(uint _votingIndex, address _votingFor) external isAddressInVoting(_votingIndex, _votingFor) payable {
        require(votings[_votingIndex].endAt > block.timestamp, "Ended");

        for (uint i = 0; i < votings[_votingIndex].candidates.length; i++) {
            if (votings[_votingIndex].candidates[i].candidateAddress == _votingFor) {
                votings[_votingIndex].candidates[i].votes += msg.value;
                break;
            }
        }
        
        address currentLeader = votings[_votingIndex].candidates[0].candidateAddress;
        uint currentMaxVote = votings[_votingIndex].candidates[0].votes;
        
        for (uint i = 1; i < votings[_votingIndex].candidates.length; i++) {
            if (votings[_votingIndex].candidates[i].votes > currentMaxVote) {
                currentLeader = votings[_votingIndex].candidates[i].candidateAddress;
                currentMaxVote = votings[_votingIndex].candidates[i].votes;
            }
        }

        votings[_votingIndex].winner = currentLeader;
        votings[_votingIndex].finalVote = currentMaxVote;



    }

    function getInfo(uint _votingIndex) external view returns(Candidate[] memory, string memory, uint) {
        return (votings[_votingIndex].candidates, votings[_votingIndex].description, votings[_votingIndex].endAt);
    }

    function getVotingDetails(uint _votingIndex) external view returns(VotingDetails memory) {
        return votings[_votingIndex];
    }

    function winnerWithdraw(uint _votingIndex) external {
        require(votings[_votingIndex].winner == msg.sender, "You are not a winner");
        require(!votings[_votingIndex].winnerWithdrawed, "You already withdrawed!");
        uint totalToWithdraw;

        for (uint i; i < votings[_votingIndex].candidates.length; i++) {
            totalToWithdraw += votings[_votingIndex].candidates[i].votes;
        }

    votings[_votingIndex].platformFee = votings[_votingIndex].finalVote * 5 /100;
    uint finalAmount = votings[_votingIndex].finalVote - votings[_votingIndex].platformFee;
    feeForOwner += votings[_votingIndex].platformFee;
    
    votings[_votingIndex].winnerWithdrawed = true;
    payable(msg.sender).transfer(finalAmount);
    payable(owner).transfer(feeForOwner);

    }







}