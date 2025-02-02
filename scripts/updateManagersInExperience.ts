import { Wallet, Provider, Contract } from "zksync-web3";
import ExperienceABI from "../ABI/ExperienceABI.json";
import CampaignManagerABI from "../ABI/CampaignManagerABI.json";
import PublisherManagerABI from "../ABI/PublisherManagerABI.json";
import * as ethers from "ethers";
import addresses from "../deployments.json";
import { config } from "dotenv";
config();

async function updateManagers() {
  console.log(`Running Manager Update script`);

  // set address of publisher manager and campaign manager in experience
  // set address of experience = 1, publisher manager = 2, holdingwallet = 3 in campaign manager
  // set address of holding wallet = true, experience = false in publisher manager
  const zksyncProvider = process.env.ZKSYNC_PROVIDER as string;
  const privateKey = process.env.PRIVATE_KEY as string;
  const l2Provider = new Provider(zksyncProvider);
  const wallet = new Wallet(privateKey, l2Provider);

  const ExperienceContractAddress = addresses["Experience"];
  const PublisherManagerAddress = addresses["PublisherManager"];
  const CampaignManagerAddress = addresses["CampaignManager"];
  const HoldingWalletAddress = addresses["HoldingWallet"];

  const ExperienceContract = new Contract(
    ExperienceContractAddress,
    ExperienceABI,
    wallet._signerL2()
  );

  const tx1 = await ExperienceContract.setPublisherManager(
    PublisherManagerAddress
  );
  await tx1.wait();

  const tx2 = await ExperienceContract.setCampaignManager(
    CampaignManagerAddress
  );
  await tx2.wait();
  console.log("Experience contract updated");

  const PublisherManagerContract = new Contract(
    PublisherManagerAddress,
    PublisherManagerABI,
    wallet._signerL2()
  );

  const tx3 = await PublisherManagerContract.updateAddress(
    HoldingWalletAddress,
    true
  );
  await tx3.wait();

  const tx4 = await PublisherManagerContract.updateAddress(
    ExperienceContractAddress,
    false
  );
  await tx4.wait();
  console.log("PublisherManager contract updated");

  const CampaignManagerContract = new Contract(
    CampaignManagerAddress,
    CampaignManagerABI,
    wallet._signerL2()
  );

  const tx5 = await CampaignManagerContract.updateAddress(
    ExperienceContractAddress,
    1
  );
  await tx5.wait();

  const tx6 = await CampaignManagerContract.updateAddress(
    PublisherManagerAddress,
    2
  );
  await tx6.wait();

  const tx7 = await CampaignManagerContract.updateAddress(
    HoldingWalletAddress,
    3
  );
  await tx7.wait();

  console.log("CampaignManager contract updated");
}

updateManagers().catch((e) => {
  console.error(e);
  process.exit(1);
});
