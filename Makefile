# £ack this file was originally copied from https://github.com/Cyfrin/foundry-erc20-f23/blob/main/Makefile
# £todo: it needs a clean up.  

-include .env

# .PHONY: all test clean deploy fund help install snapshot format anvil 

all: clean remove install update build

# Clean the repo
clean  :; forge clean

# Remove modules
# NB: contract is now broken on incompatible versions (seemingly internally in openZeppelin). 
remove :; rm -rf .gitmodules && rm -rf .git/modules/* && rm -rf lib && touch .gitmodules && git add . && git commit -m "modules"

# Install modules
install :; forge install foundry-rs/forge-std --no-commit && forge install openzeppelin/openzeppelin-contracts --no-commit

# Update Dependencies
update:; forge update

# Build
build:; forge build

test :; forge test 

snapshot :; forge snapshot

format :; forge fmt

anvil :; anvil -m 'test test test test test test test test test test test junk' --steps-tracing --block-time 1

# Verify already deployed contract - example 
verify:
	@forge verify-contract --chain-id 11155111 --num-of-optimizations 200 --watch --constructor-args 0x00000000000000000000000000000000000000000000d3c21bcecceda1000000 --etherscan-api-key $(OPT_ETHERSCAN_API_KEY) --compiler-version v0.8.19+commit.7dd6d404 0x089dc24123e0a27d44282a1ccc2fd815989e3300 src/OurToken.sol:OurToken

###############################
# 			Sepolia testnet				#
###############################
SEPOLIA_FORKED_TEST_ARGS := --fork-url $(SEPOLIA_RPC_URL) 
SEPOLIA_FORKED_DEPLOY_ARGS := --rpc-url $(SEPOLIA_RPC_URL) --account dev_2 --sender ${DEV2_ADDRESS} --broadcast --verify --etherscan-api-key $(ETHERSCAN_API_KEY) -vvvv

sepoliaForkedDeployLoyaltyCard6551AccountTest: 
	@forge script script/DeployLoyaltyCard6551Account.s.sol:DeployLoyaltyCard6551Account $(SEPOLIA_FORKED_TEST_ARGS)

sepoliaForkedDeployLoyaltyCard6551Account: 
	@forge script script/DeployLoyaltyCard6551Account.s.sol:DeployLoyaltyCard6551Account $(SEPOLIA_FORKED_DEPLOY_ARGS)

sepoliaForkedTest: 
	@forge test --no-match-contract ContinueOn $(SEPOLIA_FORKED_TEST_ARGS) 
	
sepoliaForkedDeployTest: 
	@forge script script/DeployLoyaltyProgram.s.sol:DeployLoyaltyProgram $(SEPOLIA_FORKED_TEST_ARGS)

sepoliaForkedDeploy:
	@forge script script/DeployLoyaltyProgram.s.sol:DeployLoyaltyProgram $(OPT_SEPOLIA_FORKED_DEPLOY_ARGS)

###############################
# 		OPSepolia testnet				#
###############################
OPT_SEPOLIA_FORKED_TEST_ARGS := --fork-url $(OPT_SEPOLIA_RPC_URL) 
OPT_SEPOLIA_FORKED_DEPLOY_ARGS := --rpc-url $(OPT_SEPOLIA_RPC_URL) --account dev_2 --sender ${DEV2_ADDRESS} --broadcast --verify --etherscan-api-key $(OPT_ETHERSCAN_API_KEY) -vvvv

optSepoliaForkedTest: 
	@forge test --no-match-contract ContinueOn  $(OPT_SEPOLIA_FORKED_TEST_ARGS)

sepoliaForkedDeployLoyaltyCard6551AccountTest: 
	@forge script script/DeployLoyaltyCard6551Account.s.sol:DeployLoyaltyCard6551Account $(OPT_SEPOLIA_FORKED_TEST_ARGS)

sepoliaForkedDeployLoyaltyCard6551Account: 
	@forge script script/DeployLoyaltyCard6551Account.s.sol:DeployLoyaltyCard6551Account $(OPT_SEPOLIA_FORKED_DEPLOY_ARGS)


optSepoliaForkedDeployTest: 
	@forge script script/DeployLoyaltyProgram.s.sol:DeployLoyaltyProgram $(OPT_SEPOLIA_FORKED_TEST_ARGS)
	
optSepoliaForkedDeploy: 
	@forge script script/DeployLoyaltyProgram.s.sol:DeployLoyaltyProgram $(OPT_SEPOLIA_FORKED_DEPLOY_ARGS)


############################################## 
#     Arbitrum Sepolia testnet							 #
##############################################
ARB_SEPOLIA_FORK_TEST_ARGS := --fork-url $(ARB_SEPOLIA_RPC_URL) 
ARB_SEPOLIA_FORK_ARGS := --fork-url $(ARB_SEPOLIA_RPC_URL) --broadcast --account dev_2 --sender ${DEV2_ADDRESS} --verify --etherscan-api-key $(ETHERSCAN_API_KEY)
ARB_SEPOLIA_ARGS := --rpc-url $(ARB_SEPOLIA_RPC_URL) --account dev_2 --sender ${DEV2_ADDRESS} --broadcast --verify --etherscan-api-key $(ETHERSCAN_API_KEY) -vvvv

arbSepoliaForkTest: # notice that invariant tests are excluded (takes too long). 
	@forge test --no-match-contract ContinueOn $(ARB_SEPOLIA_FORK_TEST_ARGS)  

arbSepoliaTestDeploy: 
	@forge script script/DeployLoyaltyProgram.s.sol:DeployLoyaltyProgram $(ARB_SEPOLIA_FORK_TEST_ARGS)

arbSepoliaForkDeploy: 
	@forge script script/DeployLoyaltyProgram.s.sol:DeployLoyaltyProgram $(ARB_SEPOLIA_FORK_ARGS)
# @forge script script/DeployLoyaltyGifts.s.sol:DeployMockLoyaltyGifts $(ARB_SEPOLIA_FORK_ARGS)

arbSepoliaDeploy:
	@forge script script/DeployLoyaltyProgram.s.sol:DeployLoyaltyProgram $(ARB_SEPOLIA_ARGS)
	@forge script script/DeployLoyaltyGifts.s.sol:DeployMockLoyaltyGifts $(ARB_SEPOLIA_ARGS)

# cast abi-encode "constructor(uint256)" 1000000000000000000000000 -> 0x00000000000000000000000000000000000000000000d3c21bcecceda1000000
# Update with your contract address, constructor arguments and anything else

###############################
# 			 Local testnet				#
###############################
ANVIL_ARGS_0 := --rpc-url http://localhost:8545 --private-key $(DEFAULT_ANVIL_KEY_0) --broadcast
ANVIL_ARGS_1 := --rpc-url http://localhost:8545 --private-key $(DEFAULT_ANVIL_KEY_1) --broadcast
ANVIL_TEST_ARGS := --rpc-url http://localhost:8545

#NB: DO NOT FORGET TO INITIATE REGISTRY, using script at cloning/reference. 
anvilDeployLoyaltyProgram:
	@forge script script/DeployLoyaltyProgram.s.sol:DeployLoyaltyProgram $(ANVIL_ARGS_1)

anvilDeployLoyaltyCard6551Account: 
	@forge script script/DeployLoyaltyCard6551Account.s.sol:DeployLoyaltyCard6551Account $(ANVIL_ARGS_0)

anvilDeployGifts:
	@forge script ../loyalty-gifts-contracts/script/DeployFridaysFifteenPercent.s.sol:DeployFridaysFifteenPercent $(ANVIL_ARGS_0)
	@forge script ../loyalty-gifts-contracts/script/DeployPointsForLoyaltyGifts.s.sol:DeployPointsForLoyaltyGifts $(ANVIL_ARGS_0)
	@forge script ../loyalty-gifts-contracts/script/DeployPointsForLoyaltyVouchers.s.sol:DeployPointsForLoyaltyVouchers $(ANVIL_ARGS_0)
	@forge script ../loyalty-gifts-contracts/script/DeployPointsForPseudoRaffle.s.sol:DeployPointsForPseudoRaffle $(ANVIL_ARGS_0)
	@forge script ../loyalty-gifts-contracts/script/DeployTieredAccess.s.sol:DeployTieredAccess $(ANVIL_ARGS_0)

anvilDeployAll: 
	@forge script script/DeployLoyaltyProgram.s.sol:DeployLoyaltyProgram $(ANVIL_ARGS_1)
	@forge script ../loyalty-gifts-contracts/script/DeployFridaysFifteenPercent.s.sol:DeployFridaysFifteenPercent $(ANVIL_ARGS_0)
	@forge script ../loyalty-gifts-contracts/script/DeployPointsForLoyaltyGifts.s.sol:DeployPointsForLoyaltyGifts $(ANVIL_ARGS_0)
	@forge script ../loyalty-gifts-contracts/script/DeployPointsForLoyaltyVouchers.s.sol:DeployPointsForLoyaltyVouchers $(ANVIL_ARGS_0)
	@forge script ../loyalty-gifts-contracts/script/DeployPointsForPseudoRaffle.s.sol:DeployPointsForPseudoRaffle $(ANVIL_ARGS_0)
	@forge script ../loyalty-gifts-contracts/script/DeployTieredAccess.s.sol:DeployTieredAccess $(ANVIL_ARGS_0)

# £todo add this text to readme files. 
# All tests need to be run through local anvil chain, with a registry deployed locally. 
# all contracts here run on solc 0.8.24; while erc-6551 registry runs on solc 0.8.19. 
# Due to changes in OpenZeppelin contracts, these cannot be deployed from the same folder / environment.

# £todo take out the following: 
# anvilTest:
# 	@forge test $(ANVIL_TEST_ARGS)

