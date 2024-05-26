async function main() {
  const [companyA, companyB] = await ethers.getSigners();

  console.log("Deploying contracts with the company account:", companyA.address);

  const balance = await companyA.getBalance();

  const ServiceAgreement = await ethers.getContractFactory("ServiceAgreement");
  const milestonePayments = [
    ethers.utils.parseEther("1"),
    ethers.utils.parseEther("2"),
    ethers.utils.parseEther("3"),
  ];
  const milestoneDeadlines = [1725097600, 1727689600, 1730281600];
  const totalContractValue = ethers.utils.parseEther("6");
  const serviceAgreement = await ServiceAgreement.deploy(
    companyA.address,
    companyB.address,
    milestonePayments.length,
    milestonePayments,
    milestoneDeadlines,
    totalContractValue,
    { value: totalContractValue }
  );
  console.log("ServiceAgreement deployment hash:", serviceAgreement.deployTransaction.hash);
  console.log("ServiceAgreement deployed to:", serviceAgreement.address);
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
