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


import { ethers } from "hardhat";
import chai from "chai";
import { solidity } from "ethereum-waffle";
import { CommunityGarden } from "../typechain/CommunityGarden";

chai.use(solidity);
const { expect } = chai;

describe("Community Garden", function() {
  let communityGarden: CommunityGarden;

  beforeEach(async function() {
    // Deploying the contract before each test
    // Set initial total plots to 10 and max plots per person to 2
    const CommunityGardenFactory = await ethers.getContractFactory("CommunityGarden");
    communityGarden = (await CommunityGardenFactory.deploy(10, 2)) as CommunityGarden;
    await communityGarden.deployed();
  });

  // Test that a user can claim a plot
  it("Should claim a plot", async function() {
    await communityGarden.claimPlot(1);
    const plotOwner = await communityGarden.getPlotOwner(1);
    expect(plotOwner).to.equal(await ethers.provider.getSigner().getAddress());
  });

  // Test that a user cannot claim more than the max number of plots per person
  it("Should not allow to claim more than max plots per person", async function() {
    await communityGarden.claimPlot(1);
    await communityGarden.claimPlot(2);

    await expect(communityGarden.claimPlot(3)).to.be.revertedWith("You have reached your plot limit");
  });

  // Test that the manager can reset a plot
  it("Should reset a plot", async function() {
    await communityGarden.claimPlot(1);
    const manager = await ethers.provider.getSigner().getAddress();
    await communityGarden.resetPlot(1);
    const plotOwner = await communityGarden.getPlotOwner(1);
    expect(plotOwner).to.equal(ethers.constants.AddressZero);
  });

  // Test that a plot owner can transfer the plot to a new owner
  it("Should transfer a plot", async function() {
    // claim the first plot
    const [signer1, signer2] = await ethers.getSigners();
    const communityGardenWithSigner1 = communityGarden.connect(signer1);
    await communityGardenWithSigner1.claimPlot(1);

    // transfer the first plot to the second address
    await communityGardenWithSigner1.transferPlot(1, await signer2.getAddress());

    // check the new owner of the first plot
    const newOwner = await communityGarden.getPlotOwner(1);
    expect(newOwner).to.equal(await signer2.getAddress());
  });

  // Test that the manager can change the max plots per person
  it("Should change max plots per person", async function() {
    const manager = await ethers.provider.getSigner().getAddress();
    await communityGarden.changeMaxPlotsPerPerson(3);
    const newMax = await communityGarden.maxPlotsPerPerson();
    expect(newMax).to.equal(3);
  });

  // Test that plot availability can be checked correctly
  it("Should verify plot availability", async function() {
    // Check availability of an unclaimed plot
    let availability = await communityGarden.isPlotAvailable(1);
    expect(availability).to.be.true;

    // Claim the plot
    await communityGarden.claimPlot(1);

    // Check availability again
    availability = await communityGarden.isPlotAvailable(1);
    expect(availability).to.be.false;
  });
});
