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


import { ethers, run } from "hardhat";


async function main() {
  // Compile our contract
  await run('compile');

  // Get the contract factory
  const CommunityGarden = await ethers.getContractFactory("CommunityGarden");

  // Deploy the contract with totalPlots set to 100 and maxPlotsPerPerson set to 5
  const communityGarden = await CommunityGarden.deploy(100, 5);
  
  // Wait for the transaction to be mined
  await communityGarden.deployed();

  console.log("CommunityGarden deployed to:", communityGarden.address);
}

main()
  .then(() => process.exit(0))
  .catch(error => {
    console.error(error);
    process.exit(1);
  });
