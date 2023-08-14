# Minimal `Vat` setup

## Setup localchain using GETH

```bash
geth --datadir ~/.temp/ --dev --http --http.api web3,eth,debug,net --http.corsdomain "*" --http.vhosts "*" --http.addr 127.0.0.1 --ws --ws.api eth,net,debug,web3 --ws.addr 127.0.0.1 --ws.origins "*" --graphql --graphql.corsdomain "*" --graphql.vhosts "*" --vmdebug
```

## Setup local environment variables

export ETH_FROM=0x
export FOUNDRY_ETH_FROM=$ETH_FROM
export ETHERSCAN_API_KEY=""
export POLYGONSCAN_API_KEY=""
export ETH_KEYSTORE="/Users/johndoe/temp/keystore"
export FOUNDRY_ETH_KEYSTORE_DIR=$ETH_KEYSTORE
export ETH_PASSWORD="$ETH_KEYSTORE/passwd.txt"
export FOUNDRY_ETH_PASSWORD_FILE=$ETH_PASSWORD


## Deploy `Vat`

0. Deploy `Vat` from `vat.sol`

Example:

```bash
forge-script.sh ../src/SampleVat.s.sol:SampleVatDeploy --fork-url=$RPC_URL --broadcast -vvvv
```

## Deploy your ERC-20 token `$CENT`

0. Deploy an ERC-20 that you control



## Deploy `GemJoin`

0. Deploy a `GemJoin` contract from `join.sol`
    ```solidity
    GemJoin(address vat, bytes32 ilk, address gem)
    ```
    - `vat`: `<vat_addr>`
    - `ilk`: `'CENT-A'`
    - `gem`: `$CENT` ERC20 token address

## Deploy your own "Dai" token `$DAI`

0. Deploy an ERC-20 that you control

Example:

```bash
forge-script.sh ../src/Cent.s.sol:CenturionDaiDeploy --fork-url=$RPC_URL --broadcast -vvvv
```

## Authorize the contracts on the `Vat`:

0. `rely` on both join contracts:
    ```solidity
    vat.rely(<gem_join_addr>);
    vat.rely(<dai_join_addr>);
    ```

## Deploy `DaiJoin`

0. Deploy a `DaiJoin` contract from `join.sol`
    ```solidity
    DaiJoin(address vat, address dai)
    ```
    - `vat`: `<vat_addr>`
    - `gem`: `$MYDAI` ERC20 token address
1. Allow `DaiJoin` to **mint** `$MYDAI`
1. Allow `DaiJoin` to **burn** `$MYDAI`

## Initialize the collateral type

1. Initialize Vat for `CENT-A`
    ```solidity
    vat.init('CENT-A');
    ```
2. Set the global debt ceiling `Line` (with capital `L`)
    ```solidity
    vat.file('Line', 1_000_000 * 10**45); // RAD: 45 decimals
    ```
3. Set collateral debt ceiling `line` (with lower `l`)
    ```solidity
    vat.file('CENT-A', 'line', 1_000_000 * 10**45); // RAD: 45 decimals
    ```
4. Set collateral price (`spot`)
    ```solidity
    vat.file('CENT-A', 'spot', 1 * 10**27) // RAY: 27 decimals 
    ```
    - This makes so 1 `$CENT` = 1 `DAI` and that the collateralization ratio is 100%

## Borrow `$MYDAI` from `$CENT`

1. Approve `GemJoin` to spend your `$CENT`
    ```solidity
    cent.approve(<gem_join_addr>, type(uint256).max);
    ```
2. Add your `$CENT` to the protocol by calling `GemJoin.join()`:
    ```solidity
    gemJoin.join(<your_addr>, <amount>); // <amount> with 10**18 precision
    ```
    - This will add collateral to the system, but it will remain **unemcumbered** (not locked).
3. Draw internal `dai` from the `Vat` using `frob()`:
    ```solidity
    vat.frob(
        'CENT-A', // ilk
        <your_wallet>,
        <your_wallet>,
        <your_wallet>, // To keep it simple, use your address for both `u`, `v` and `w`
        int dink, // with 10**18 precision
        int dart // with 10**18 precision
    )
    ```
    - `dink`: how much collateral to lock(+)/unlock(-)
        - Collateral is now **encumbered** (locked) into the system.
    - `dart`: how much **normalized debt** to add(+)/remove(-)
        - Remember that `debt = ilk.rate * urn.art`
        - To get the value for `dart`, divide the desired amount by `ilk.rate` (this is a floating point division, which can be tricky)
            - See the [RwaUrn](https://github.com/makerdao/rwa-toolkit/blob/8d30ed2cb657641253d45b57c894613e26b4ae1b/src/urns/RwaUrn.sol#L156-L178) component to understand how it can be done
    - Recommendation: respect `dink = dart/2` when drawing
4. Get ERC-20 `$MYDAI`
    ```solidity
    daiJoin.exit(<your_wallet>, <amount>); // <amount> with 10**18 precision
    ```

## Repay your loan to get `$CENT` back

1. Approve `DaiJoin` to spend your `$MYDAI`
    ```solidity
    dai.approve(<dai_join_addr>, type(uint256).max);
    ```
2. Add your `$MYDAI` to the protocol by calling `DaiJoin.join()`:
    ```solidity
    daiJoin.join(<your_addr>, <amount>); // <amount> with 10**18 precision
    ```
    - This will burn ERC-20 `$MYDAI` and add it to `<your_addr>` internal balance on the `Vat`.
3. Repay internal `dai` in the `Vat` using `frob()`:
    ```solidity
    vat.frob(
        'CENT-A', // ilk
        <your_wallet>,
        <your_wallet>,
        <your_wallet>, // To keep it simple, use your address for both `u`, `v` and `w`
        int dink, // with 10**18 precision
        int dart // with 10**18 precision
    )
    ```
    - `dink`: how much collateral to unlock. **MUST BE NEGATIVE**
        - Collateral is now **uncumbered** (unlocked), but still in the system.
    - `dart`: how much **normalized debt** to remove. **MUST BE NEGATIVE**
        - Remember that `debt = ilk.rate * urn.art`
        - To get the value for `dart`, divide the desired amount by `ilk.rate` (this is a floating point division, which can be tricky)
            - See the [RwaUrn](https://github.com/makerdao/rwa-toolkit/blob/8d30ed2cb657641253d45b57c894613e26b4ae1b/src/urns/RwaUrn.sol#L156-L178) component to understand how it can be done
4. Get your `$CENT` back:
    ```solidity
    gemJoin.exit(<your_wallet>, <amount>); // <amount> with 10**18 precision
    ```
