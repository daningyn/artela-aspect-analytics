"use strict"

const fs = require('fs');
const Web3 = require('@artela/web3');
var argv = require('yargs')
    .string('token')
    .string('abi')
    .string('amount')
    .parserConfiguration({
        "parse-numbers": false,
    })
    .argv;

const mintTokens = async () => {
  const abiPath = String(argv.abi || '');
  if (!abiPath) {
    console.log("'abi' cannot be empty, please set by the parameter' --abi xxx/xxx.abi'")
    process.exit(0)
  }
  const abiTxt = fs.readFileSync(abiPath, "utf-8").toString().trim();
  const abi = JSON.parse(abiTxt);

  const configJson = JSON.parse(fs.readFileSync('./project.config.json', "utf-8").toString());
  const web3 = new Web3(configJson.node);

  const tokenAddress = String(argv.token);
  if (!tokenAddress) {
    console.log('"token" cannot be empty, please set by the parameter --token 0x...');
    process.exit(0);
  }
  const contractAddress = tokenAddress;

  const senderPriKey = "privateKey.txt"
  if (!fs.existsSync(senderPriKey)) {
    console.log("'account' cannot be empty, please set private key in the file privateKey.txt");
    process.exit(0);
  }
  let pk = fs.readFileSync(senderPriKey, 'utf-8');
  let sender = web3.eth.accounts.privateKeyToAccount(pk.trim());
  await web3.eth.accounts.wallet.add(sender.privateKey);
  console.log("from address: ", sender.address);
  const ownerAddress = sender.address;

  const contract = new web3.eth.Contract(abi, contractAddress);
  // mint token
  const amount = String(argv.amount || '');
  if (!amount) {
    console.log('"amount" cannot be empty, please set amount by --amount x');
    process.exit(0);
  }
  const amountToMint = web3.utils.toBN(amount).mul(web3.utils.toBN(10).pow(web3.utils.toBN('18')));
  const result = await contract.methods.mint(ownerAddress, amountToMint.toString()).send({
    from: ownerAddress,
    gas: 100000,
  });
  console.log('Tokens minted:', result);
}

mintTokens();