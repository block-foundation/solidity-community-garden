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


pragma solidity ^0.8.7;


contract CommunityGarden {
    address public manager;
    mapping (uint => address) public gardenPlots;
    mapping (address => uint) public ownerPlotCount;

    uint public totalPlots;
    uint public maxPlotsPerPerson;

    event PlotClaimed(uint indexed plot, address indexed newOwner);
    event PlotReset(uint indexed plot, address indexed previousOwner);
    
    constructor(uint _totalPlots, uint _maxPlotsPerPerson) {
        require(_totalPlots > 0, "Total plots must be greater than zero");
        require(_maxPlotsPerPerson > 0, "Max plots per person must be greater than zero");
        
        manager = msg.sender;
        totalPlots = _totalPlots;
        maxPlotsPerPerson = _maxPlotsPerPerson;
    }

    function claimPlot(uint plot) public {
        // check if the plot number is valid
        require(plot < totalPlots, "Invalid plot number");

        // check if the plot is not yet claimed
        require(gardenPlots[plot] == address(0), "Plot already claimed");

        // check if the claimer has not reached the max plot count
        require(ownerPlotCount[msg.sender] < maxPlotsPerPerson, "You have reached your plot limit");
        
        // claim the plot
        gardenPlots[plot] = msg.sender;

        // increment the plot count for this owner
        ownerPlotCount[msg.sender]++;

        // emit the event
        emit PlotClaimed(plot, msg.sender);
    }

    function getPlotOwner(uint plot) public view returns (address) {
        return gardenPlots[plot];
    }

    function resetPlot(uint plot) public {
        // only the manager can reset the plot
        require(msg.sender == manager, "Only the manager can reset the plot");
        
        // decrease the plot count for the current owner
        address previousOwner = gardenPlots[plot];
        ownerPlotCount[previousOwner]--;

        // reset the plot
        gardenPlots[plot] = address(0);

        // emit the event
        emit PlotReset(plot, previousOwner);
    }

    function changeMaxPlotsPerPerson(uint newMax) public {
        // only the manager can change the max plots per person
        require(msg.sender == manager, "Only the manager can change the max plots per person");
        
        // change the max plots per person
        maxPlotsPerPerson = newMax;
    }

    function transferPlot(uint plot, address newOwner) public {
        // only the current owner or the manager can transfer the plot
        require(gardenPlots[plot] == msg.sender || msg.sender == manager, "You are not allowed to transfer this plot");

        // the new owner must not exceed the max plot count
        require(ownerPlotCount[newOwner] < maxPlotsPerPerson, "The new owner has reached their plot limit");

        // decrease the plot count for the current owner
        if (gardenPlots[plot] != manager) {
            ownerPlotCount[gardenPlots[plot]]--;
        }

        // increase the plot count for the new owner
        ownerPlotCount[newOwner]++;

        // transfer the plot
        gardenPlots[plot] = newOwner;

        // emit the event
        emit PlotClaimed(plot, newOwner);
    }

    function isPlotAvailable(uint plot) public view returns (bool) {
        return gardenPlots[plot] == address(0);
    }
}
