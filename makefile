# Load environment variables from .env
include .env
export $(shell sed 's/=.*//' .env)

# Formatting and Testing prerequisite
.PHONY: check
check:
	forge fmt
	forge test

# Deployment targets
IDrisToken: check
	forge script script/IDrisToken.s.sol --rpc-url lisk-sepolia --broadcast --verify

EventManager: check
	forge script script/EventManager.s.sol --rpc-url lisk-sepolia --broadcast --verify

IDrisToken-local: check
	forge script script/IDrisToken.s.sol --rpc-url localhost --broadcast
	# Ensure the DO_NOT_KEY is updated in the env file.

EventManager-local: check
	forge script script/EventManager.s.sol --rpc-url localhost --broadcast
	# Ensure the DO_NOT_KEY is updated in the env file.
