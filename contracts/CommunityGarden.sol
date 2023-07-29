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


// ============================================================================
// Contracts
// ============================================================================

/// Community Garden Contract
/// @title CommunityGarden
/// @author Your Name or Organization
/// @notice This contract represents a community garden where people can claim, transfer, and manage garden plots.
/// @dev All function calls are currently implemented without side effects.
contract CommunityGarden {

    /// @notice The address of the manager of the garden
    address public manager;

    /// @notice Total number of plots in the community garden
    uint public totalPlots;

    /// @notice Maximum number of plots that one person can claim
    uint public maxPlotsPerPerson;

    /// @dev A struct representing a plot in the community garden
    struct Plot {
        address owner;
        string plant;
    }

    /// @dev An array of all plots in the garden
    Plot[] public plots;

    // Constructor
    // ========================================================================

    /// @notice Creates a new community garden contract
    /// @param _totalPlots The total number of plots in the garden
    /// @param _maxPlotsPerPerson The maximum number of plots a single person can claim
    constructor(
        uint _totalPlots,
        uint _maxPlotsPerPerson
    ) {
        require(
            _totalPlots > 0,
            "Total plots must be greater than zero"
        );
        require(
            _maxPlotsPerPerson > 0,
            "Max plots per person must be greater than zero"
        );
        
        /// @dev Set the manager as the account that deploys the contract
        manager = msg.sender;

        /// @dev Set the total number of plots
        totalPlots = _totalPlots;

        /// @dev Set the maximum number of plots per person
        maxPlotsPerPerson = _maxPlotsPerPerson;
    }
        // Mappings
    // ========================================================================

    /// @notice Represents the owner of each plot in the garden
    /// @dev Maps a plot number (uint) to an owner's address
    mapping (uint => address) public gardenPlots;

    /// @notice Represents the number of plots owned by each user
    /// @dev Maps an owner's address to their plot count (uint)
    mapping (address => uint) public ownerPlotCount;


    // Events
    // ========================================================================

    /// @notice Event emitted when a plot is claimed
    /// @param plot The number of the plot that was claimed
    /// @param newOwner The address of the user who claimed the plot
    event PlotClaimed(
        uint indexed plot,
        address indexed newOwner
    );

    /// @notice Event emitted when a plot is reset
    /// @param plot The number of the plot that was reset
    /// @param previousOwner The address of the user who previously owned the plot
    event PlotReset(
        uint indexed plot,
        address indexed previousOwner
    );


    // Methods
    // ========================================================================

    /**
    *   @notice Allows a user to claim a plot in the community garden.
    *   @dev Checks if the plot number is valid, if the plot is unclaimed, and
    *   if the sender hasn't exceeded their max plot limit.
    *   The function then assigns the plot to the sender and increments the
    *   sender's plot count.
    *   Emits a PlotClaimed event.
    *   @param plot The number of the plot to claim.
    */
    function claimPlot(
        uint plot
    ) public {

        // check if the plot number is valid
        require(
            plot < totalPlots,
            "Invalid plot number"
        );

        // check if the plot is not yet claimed
        require(
            gardenPlots[plot] == address(0),
            "Plot already claimed"
        );

        // check if the claimer has not reached the max plot count
        require(
            ownerPlotCount[msg.sender] < maxPlotsPerPerson,
            "You have reached your plot limit"
        );
        
        // claim the plot
        gardenPlots[plot] = msg.sender;

        // increment the plot count for this owner
        ownerPlotCount[msg.sender]++;

        // emit the event
        emit PlotClaimed(plot, msg.sender);
    }

    /**
    *   @notice Allows a user to check who owns a particular plot.
    *   @dev Returns the address of the owner of the specified plot.
    *   @param plot The number of the plot to check.
    *   @return The address of the owner of the specified plot.
    */
    function getPlotOwner(
        uint plot
    ) public view returns (address) {
        return gardenPlots[plot];
    }
    /**
    *   @notice Resets a plot, freeing it up to be claimed again.
    *   @dev Can only be called by the manager. Decreases the previous owner's
    *   plot count, clears the owner of the plot, and emits a PlotReset event.
    *   @param plot The number of the plot to reset.
    */
    function resetPlot(
        uint plot
    ) public {

        // only the manager can reset the plot
        require(
            msg.sender == manager,
            "Only the manager can reset the plot"
        );
        
        // decrease the plot count for the current owner
        address previousOwner = gardenPlots[plot];
        ownerPlotCount[previousOwner]--;

        // reset the plot
        gardenPlots[plot] = address(0);

        // emit the event
        emit PlotReset(plot, previousOwner);
    }

    /**
     * @notice Changes the maximum number of plots that each person can own.
     * @dev Can only be called by the manager.
     * @param newMax The new maximum number of plots per person.
     */
    function changeMaxPlotsPerPerson(
        uint newMax
    ) public {

        // only the manager can change the max plots per person
        require(
            msg.sender == manager,
            "Only the manager can change the max plots per person"
        );
        
        // change the max plots per person
        maxPlotsPerPerson = newMax;
    }

    /**
     * @notice Transfers a plot to a new owner.
     * @dev Can only be called by the current owner or the manager. Checks if the new owner hasn't exceeded their max plot limit, then decreases the previous owner's plot count, increases the new owner's plot count, changes the owner of the plot, and emits a PlotClaimed event.
     * @param plot The number of the plot to transfer.
     * @param newOwner The address of the user to transfer the plot to.
     */
    function transferPlot(
        uint plot,
        address newOwner
    ) public {

        // only the current owner or the manager can transfer the plot
        require(
            gardenPlots[plot] == msg.sender || msg.sender == manager,
            "You are not allowed to transfer this plot"
        );

        // the new owner must not exceed the max plot count
        require(
            ownerPlotCount[newOwner] < maxPlotsPerPerson,
            "The new owner has reached their plot limit"
        );

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

    /**
     * @notice Checks if a plot is available.
     * @dev A plot is available if it has no current owner.
     * @param plot The number of the plot to check.
     * @return A boolean indicating if the plot is available.
     */
    function isPlotAvailable(
        uint plot
    ) public view returns (bool) {
        return gardenPlots[plot] == address(0);
    }


}
