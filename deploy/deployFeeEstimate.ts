import { Wallet, utils } from "zksync-web3";
import * as ethers from "ethers";
import { HardhatRuntimeEnvironment } from "hardhat/types";
import { Deployer } from "@matterlabs/hardhat-zksync-deploy";
import * as dotenv from "dotenv";
dotenv.config();

// An example of a deploy script that will deploy and call a simple contract.
export default async function (hre: HardhatRuntimeEnvironment) {
  console.log(`Running fee estimate`);

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

  const deploymentFeeHoldingWallet = await deployer.estimateDeployFee(
    artifactHoldingWallet,
    []
  );
  const deploymentFeeExperience = await deployer.estimateDeployFee(
    artifactExperience,
    []
  );

  const deploymentFeePublisherManager = await deployer.estimateDeployFee(
    artifactPublisherManger,
    []
  );

  const deploymentFeeCampaignManager = await deployer.estimateDeployFee(
    artifactCampaignManager,
    []
  );

  const deploymentFeeReputation = await deployer.estimateDeployFee(
    artifactReputation,
    []
  );

  const deploymentFee = ethers.utils.formatEther(
    deploymentFeeHoldingWallet
      .add(deploymentFeeCampaignManager)
      .add(deploymentFeePublisherManager)
      .add(deploymentFeeExperience)
      .add(deploymentFeeReputation)
      .toString()
  );

  console.log(`The deployment is estimated to cost ${deploymentFee} ETH`);
}
