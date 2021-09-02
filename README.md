# Elyseos

### Elys.sol:

This is a straightforward ERC20 with a Minting function. 
Once both the token contract and minting contract are deployed, ownership must be transferred to the minting contract.

Address: [0xd89cc0d2A28a769eADeF50fFf74EBC07405DB9Fc](https://ftmscan.com/address/0xd89cc0d2a28a769eadef50fff74ebc07405db9fc)

### ElysMint:

Contract to regulate the minting of the Elystoken according to the schedule. Ownership of this contract will be transferred to the DAO contract once complete.

Address: [0xF4125d8df93B09826517F551d9872Ac28c990E96](https://ftmscan.com/address/0xF4125d8df93B09826517F551d9872Ac28c990E96)

### Flower.sol:

Flower token for seed sale.

Address: [0x0e778a80448c410dc677BD1bf3F70EF442e35C39](https://ftmscan.com/token/0x0e778a80448c410dc677BD1bf3F70EF442e35C39)

### Lock.sol

Lock token for vesting.

### LockFactory.sol

Generates lock tokens for beneficiaries.

Seed Sale Address: [0x4014525e13600dA6Ab2eb89ABEd2E12CdabEC6d0](https://ftmscan.com/address/0x4014525e13600dA6Ab2eb89ABEd2E12CdabEC6d0)  - releases 5% per day over 20 days

Foundation Address: [0x41608F62D01a6faDf210677a9a2029ff05195c1f](https://ftmscan.com/address/0x41608F62D01a6faDf210677a9a2029ff05195c1f) - releases 1% per day over 100 days

Team Address: [0x19DeC8d99a786f5F876a6bD17c91E3CF0c0f0306](https://ftmscan.com/address/0x19DeC8d99a786f5F876a6bD17c91E3CF0c0f0306) - releases 1% per day over 100 days

### LockDays.sol

Modified Lock.sol to only pay out after n days (365 days on deploy)

Address: [0x549615Fc6008E498C159eaD99143541e033D2813](https://ftmscan.com/address/0x549615Fc6008E498C159eaD99143541e033D2813)
