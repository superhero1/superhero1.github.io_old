# [HERO] HeroPool
## Cardano (ADA) staking pool - by superhero1

## Tutorial
### Generate keys [OFFLINE!]
```
cardano-cli address key-gen --verification-key-file payment.vkey --signing-key-file payment.skey
cardano-cli stake-address key-gen --verification-key-file stake.vkey --signing-key-file stake.skey
cardano-cli address build --payment-verification-key-file payment.vkey --stake-verification-key-file stake.vkey --out-file payment.addr --mainnet
cardano-cli stake-address build --stake-verification-key-file stake.vkey --out-file stake.addr --mainnet
cardano-cli stake-address registration-certificate --stake-verification-key-file stake.vkey --out-file stake.cert
```

### Grab protocol.json
```
cardano-cli query protocol-parameters --mainnet --out-file protocol.json --allegra-era
```

### Stake address registration
```
cardano-cli transaction build-raw \
--tx-in <UTXO>#<INDEX> \
--tx-out $(cat payment.addr)+0 \
--invalid-hereafter 0 \
--fee 0 \
--out-file tx.raw \
--certificate-file stake.cert \
--allegra-era
```

### Calculate transaction fee
```
cardano-cli transaction calculate-min-fee \
--tx-body-file tx.raw \
--tx-in-count 1 \
--tx-out-count 1 \
--witness-count 1 \
--byron-witness-count 0 \
--mainnet \
--protocol-params-file protocol.json
```

--> Example result: 172453

```
expr <balance> - 2000000 - 172453
```
--> Example result: 502646338


### Build transaction
```
cardano-cli transaction build-raw \
--tx-in <UTXO>#<INDEX> \
--tx-out $(cat payment.addr)+502646338 \
--invalid-hereafter <MAINNET TIP SLOT + 1000> \
--fee 172453 \
--out-file tx.raw \
--certificate-file stake.cert
```

### Sign it [OFFLINE!]
```
cardano-cli transaction sign \
--tx-body-file tx.raw \
--signing-key-file payment.skey \
--signing-key-file stake.skey \
--mainnet \
--out-file tx.signed
```

### Send to blockchain
```
cardano-cli transaction submit \
--tx-file tx.signed \
--mainnet
```

### Generate stake pool keys [OFFLINE!]
```
mkdir pool-keys
cd pool-keys
```

### Generate cold keys [OFFLINE!]
```
cardano-cli node key-gen \
--cold-verification-key-file cold.vkey \
--cold-signing-key-file cold.skey \
--operational-certificate-issue-counter-file cold.counter
```

### Generate VRF key pair [OFFLINE!]
```
cardano-cli node key-gen-VRF \
--verification-key-file vrf.vkey \
--signing-key-file vrf.skey
```

### Generate KES key pair [OFFLINE!]
```
cardano-cli node key-gen-KES \
--verification-key-file kes.vkey \
--signing-key-file kes.skey
```

```
cat mainnet-shelley-genesis.json | grep KESPeriod
```
--> Example result: 129600
```
cardano-cli query tip --mainnet
```
--> Example result: 22030347

```
expr 22030347 / 129600
```
--> Example result: 169

### Generate pool certificate
```
cardano-cli node issue-op-cert \
--kes-verification-key-file kes.vkey \
--cold-signing-key-file cold.skey \
--operational-certificate-issue-counter cold.counter \
--kes-period 169 \
--out-file node.cert
```

### Generate the metadata.json file
```json
{
  "name": "HeroPool",
  "description": "Germany based data centre hosted virtual server with NVMe SSD",
  "ticker": "HERO",
  "homepage": "https://superhero1.com/cardano"
}
```

Upload it to Github or a webhost and shorten the url e.g. with git.io

### Generate metadata-hash
```
cardano-cli stake-pool metadata-hash --pool-metadata-file pool_Metadata.json
```
--> Example result: 7831293v92n83921839287vn32173v12873vn12873vn81273vn12873vn18272n

### Generate the pool registration certificate [OFFLINE!]
```
cardano-cli stake-pool registration-certificate \
--cold-verification-key-file cold.vkey \
--vrf-verification-key-file vrf.vkey \
--pool-pledge 0 \
--pool-cost 340000000 \
--pool-margin 0.01 \
--pool-reward-account-verification-key-file ../stake.vkey \
--pool-owner-stake-verification-key-file ../stake.vkey \
--mainnet \
--pool-relay-ipv4 <PUBLIC IP> \
--pool-relay-port 3000 \
--metadata-url https://git.io/<SHORTENED URL> \
--metadata-hash 7831293v92n83921839287vn32173v12873vn12873vn81273vn12873vn18272n \
--out-file pool-registration.cert
```

### Generate the stake delegation certificate [OFFLINE!]
```
cardano-cli stake-address delegation-certificate \
--stake-verification-key-file ../stake.vkey \
--cold-verification-key-file cold.vkey \
--out-file delegation.cert
```

Transfer kes.skey, vrf.skey and node.cert to the core / block producer node

### Start the core / block producer node
```
cardano-node run \
   --topology /home/cardano/mainnet-topology.json \
   --database-path /home/cardano/db \
   --socket-path /home/cardano/db/node.socket \
   --host-addr 10.0.0.3 \
   --port 3000 \
   --config /home/cardano/mainnet-config.json \
   --shelley-kes-key kes.skey \
   --shelley-vrf-key vrf.skey \
   --shelley-operational-certificate node.cert
```
 
### Generate transaction to register the staking pool on the blockchain
```
cardano-cli transaction build-raw \
--tx-in <UTXO>#<INDEX> \
--tx-out $(cat payment.addr)+0 \
--invalid-hereafter 0 \
--fee 0 \
--out-file tx.raw \
--certificate-file pool-registration.cert \
--certificate-file delegation.cert
```

--> Example result: 182925

### Calculate transaction fee to register the staking pool on the blockchain
```
cardano-cli transaction calculate-min-fee \
--tx-body-file tx.raw \
--tx-in-count 1 \
--tx-out-count 1 \
--mainnet \
--witness-count 1 \
--byron-witness-count 0 \
--protocol-params-file protocol.json
```

--> Example result: 186181

```
expr <balance> - 500000000 - 186181
```
--> Example result: 2460157

### Build transaction
```
cardano-cli transaction build-raw \
--tx-in <UTXO>#<INDEX> \
--tx-out $(cat payment.addr)+2460157 \
--invalid-hereafter <MAINNET TIP SLOT + 1000> \
--fee 186181 \
--out-file tx.raw \
--certificate-file pool-registration.cert \
--certificate-file delegation.cert
```

### Sign transaction [OFFLINE!]
```
cardano-cli transaction sign \
--tx-body-file tx.raw \
--signing-key-file ../payment.skey \
--signing-key-file ../stake.skey \
--signing-key-file cold.skey \
--mainnet \
--out-file tx.signed
```

### Submit transaction to blockchain
```
cardano-cli transaction submit \
--tx-file tx.signed \
--mainnet
```

### Backup ALL your keys to multiple secure locations!

### Done :)
Feel free to support me by staking on my [node](https://adastat.net/pools/c7aa65ce5417d3b667c3661a5364cdf5101359b81323c3ef8ca555d5)!
