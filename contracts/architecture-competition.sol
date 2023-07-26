// SPDX-License-Identifier: Apache-2.0


// Copyright 2023 Stichting Block Foundation
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
// http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.


pragma solidity ^0.8.19;


// ============================================================================
// Contracts
// ============================================================================

/**
 * Architectural Competition Contract
 * @dev 
 */
contract ArchitecturalCompetition {

    // Parameters
    // ========================================================================

    Entry[] public entries;
    address public organizer;
    uint public entryFee;
    uint public votingDeadline;
    bool public isWinnerDeclared = false;
    Entry public winner;


    // Struct
    // ========================================================================

    struct Entry {
        address payable competitor;
        string designUrl;
        uint voteCount;
    }


    // Constructor
    // ========================================================================

    constructor(
        uint _entryFee,
        uint _votingDurationInDays
    ) {
        organizer = msg.sender;
        entryFee = _entryFee;
        votingDeadline = block.timestamp + (_votingDurationInDays * 1 days);
    }


    // Mappings
    // ========================================================================

    mapping(address => bool) public hasVoted;


    // Events
    // ========================================================================

    event WinnerDeclared(
        address winner,
        string designUrl
    );


    // Modifiers
    // ========================================================================

    modifier onlyOrganizer {
        require(
            msg.sender == organizer,
            "Only the organizer can perform this action."
        );
        _;
    }

    modifier onlyBeforeVotingDeadline {
        require(
            block.timestamp <= votingDeadline,
            "This action can't be performed after the voting deadline."
        );
        _;
    }

    modifier onlyAfterVotingDeadline {
        require(
            block.timestamp > votingDeadline,
            "This action can only be performed after the voting deadline."
        );
        _;
    }


    // Methods
    // ========================================================================

    /**
     * submitEntry
     * @param designUrl design URL
     */
    function submitEntry(
        string memory designUrl
    ) public payable onlyBeforeVotingDeadline {
        require(
            msg.value >= entryFee,
            "Entry fee is required to participate in the competition."
        );

        entries.push(
            Entry(
                {
                    competitor: payable(msg.sender),
                    designUrl: designUrl,
                    voteCount: 0
                }
            )
        );
    }

    /**
     * vote
     * @param entryIndex entryIndex
     */
    function vote(
        uint entryIndex
    ) public onlyBeforeVotingDeadline {
        require(
            !hasVoted[msg.sender],
            "You have already voted."
        );

        require(
            entryIndex < entries.length,
            "Invalid entry index."
        );

        entries[entryIndex].voteCount++;

        hasVoted[msg.sender] = true;
    }

    /**
     * declareWinner
     */
    function declareWinner() public onlyOrganizer onlyAfterVotingDeadline {
        require(
            !isWinnerDeclared,
            "Winner has already been declared."
        );

        uint winningVoteCount = 0;
        uint winningIndex = 0;

        for (uint i = 0; i < entries.length; i++) {
            if (entries[i].voteCount > winningVoteCount) {
                winningVoteCount = entries[i].voteCount;
                winningIndex = i;
            }
        }

        winner = entries[winningIndex];
        isWinnerDeclared = true;

        emit WinnerDeclared(winner.competitor, winner.designUrl);

        // Transfer the collected entry fees to the winner
        winner.competitor.transfer(address(this).balance);
    }

}
