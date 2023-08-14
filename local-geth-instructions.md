# Local GETH testnet account notes

## Install GETH

https://geth.ethereum.org/docs/getting-started/installing-geth

Follow the instructions of the page above.

## Starting the local node

For quick tests to run GETH node in **dev** mode is a good option.
Create a geth-dev-chain directory, add it to .ignore and later you can start it using the following script.

```shell
geth --datadir ~/.temp/ --dev --http --http.api web3,eth,debug,net --http.corsdomain "*" --http.vhosts "*" --http.addr 127.0.0.1 --ws --ws.api eth,net,debug,web3 --ws.addr 127.0.0.1 --ws.origins "*" --graphql --graphql.corsdomain "*" --graphql.vhosts "*" --vmdebug

```

## Account list and tx samples

You can attach to the node via IPC and access the account

Using developer account address=0xc5ed670F7D3f9bd276fB3C5754180a6745acACE7
geth attach ipc:///Users/yourusername/temp/geth.ipc

Let's assume your coinbase/developer account is:
0xc5ed670F7D3f9bd276fB3C5754180a6745acACE7
eth.getBalance("0xc5ed670F7D3f9bd276fB3C5754180a6745acACE7")
web3.fromWei(eth.getBalance("0xc5ed670F7D3f9bd276fB3C5754180a6745acACE7"), "ether")

eth.sendTransaction({from:"0xc5ed670F7D3f9bd276fB3C5754180a6745acACE7", to:"0xb493763b409072859203c097f206dA076aD592D5", gasPrice: 875000000, value: web3.toWei(5, "ether")})

web3.fromWei(eth.getBalance("0xb493763b409072859203c097f206dA076aD592D5"), "ether")
