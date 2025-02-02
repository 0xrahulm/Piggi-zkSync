import { Wallet, utils } from "zksync-web3";
import * as ethers from "ethers";
import { HardhatRuntimeEnvironment } from "hardhat/types";
import { Deployer } from "@matterlabs/hardhat-zksync-deploy";
import * as dotenv from "dotenv";
import addresses from "../deployments.json";
import * as fs from "fs";
dotenv.config();

// An example of a deploy script that will deploy and call a simple contract.
export default async function (hre: HardhatRuntimeEnvironment) {
  console.log(`Deploying contracts`);

  // Initialize the wallet.
  const wallet = new Wallet(process.env.PRIVATE_KEY);

  // Create deployer object and load the artifact of the contract you want to deploy.
  const deployer = new Deployer(hre, wallet);
  const artifactHoldingWallet = await deployer.loadArtifact("HoldingWallet");
  const artifactExperience = await deployer.loadArtifact("FeEx");
  const artifactPublisherManger = await deployer.loadArtifact(
    "PublisherManager"
  );
  const artifactCampaignManager = await deployer.loadArtifact(
    "CampaignManager"
  );
  const artifactReputation = await deployer.loadArtifact("Reputation");
  const HoldingWalletContract = await deployer.deploy(
    artifactHoldingWallet,
    []
  );
  console.log(
    `${artifactHoldingWallet.contractName} was deployed to ${HoldingWalletContract.address}`
  );
  addresses["HoldingWallet"] = HoldingWalletContract.address;
  const ExperienceContract = await deployer.deploy(artifactExperience, []);
  console.log(
    `${artifactExperience.contractName} was deployed to ${ExperienceContract.address}`
  );
  addresses["Experience"] = ExperienceContract.address;
  const PublisherManagerContract = await deployer.deploy(
    artifactPublisherManger,
    []
  );
  console.log(
    `${artifactPublisherManger.contractName} was deployed to ${PublisherManagerContract.address}`
  );
  addresses["PublisherManager"] = PublisherManagerContract.address;
  const CampaignManagerContract = await deployer.deploy(
    artifactCampaignManager,
    []
  );
  console.log(
    `${artifactCampaignManager.contractName} was deployed to ${CampaignManagerContract.address}`
  );

  addresses["CampaignManager"] = CampaignManagerContract.address;
  const ReputationContract = await deployer.deploy(artifactReputation, []);
  console.log(
    `${artifactReputation.contractName} was deployed to ${ReputationContract.address}`
  );
  addresses["Reputation"] = ReputationContract.address;
  fs.writeFileSync("deployments.json", JSON.stringify(addresses));
}
