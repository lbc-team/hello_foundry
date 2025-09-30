# anvil --block-time 1


# userID : 1 hotwallet
cast send 0xF4A4378A91d7aFb2EC4a1bf5d80a21ae87C15e44 --value 1000000000000000000 --private-key 0xac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80 --rpc-url local

cast send 0x3C4383598A2094dc52aCba411DE7bA0b32Adb4E9 --value 1000000000000000000 --private-key 0xac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80 --rpc-url local
cast send 0x972edE2A6BD7b6Ea46E3981006D499dAf726bf9e --value 1000000000000000000 --private-key 0xac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80 --rpc-url local
cast send 0x33633C5056715DBB4a90F317c6ca81dF2d8396a9 --value 1000000000000000000 --private-key 0xac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80 --rpc-url local
cast send 0x1e8B446Ab2206445Fdb1F0458148e8D7d3Ec6399 --value 1000000000000000000 --private-key 0xac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80 --rpc-url local


# forge script script/MyERC20_2.s.sol --rpc-url local --broadcast
cast send 0x5FbDB2315678afecb367f032d93F642f64180aa3 "transfer(address to, uint256 value)" 0xF4A4378A91d7aFb2EC4a1bf5d80a21ae87C15e44 1000000000000000000000 --private-key 0xac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80 --rpc-url local

cast send 0x5FbDB2315678afecb367f032d93F642f64180aa3 "transfer(address to, uint256 value)" 0xa4eEB3c8310A8dea738173c50DaE01F1E3A68B44 900000000000000000000 --private-key 0xac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80 --rpc-url local
cast send 0x5FbDB2315678afecb367f032d93F642f64180aa3 "transfer(address to, uint256 value)" 0x3C4383598A2094dc52aCba411DE7bA0b32Adb4E9 900000000000000000000 --private-key 0xac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80 --rpc-url local
cast send 0x5FbDB2315678afecb367f032d93F642f64180aa3 "transfer(address to, uint256 value)" 0x972edE2A6BD7b6Ea46E3981006D499dAf726bf9e 900000000000000000000 --private-key 0xac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80 --rpc-url local
cast send 0x5FbDB2315678afecb367f032d93F642f64180aa3 "transfer(address to, uint256 value)" 0x33633C5056715DBB4a90F317c6ca81dF2d8396a9 900000000000000000000 --private-key 0xac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80 --rpc-url local
cast send 0x5FbDB2315678afecb367f032d93F642f64180aa3 "transfer(address to, uint256 value)" 0x1e8B446Ab2206445Fdb1F0458148e8D7d3Ec6399 900000000000000000000 --private-key 0xac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80 --rpc-url local



# forge script script/Mock_USDC_ERC20.s.sol --rpc-url local --broadcast
cast send 0x9fE46736679d2D9a65F0992F2272dE9f3c7fa6e0 "transfer(address to, uint256 value)" 0x3C4383598A2094dc52aCba411DE7bA0b32Adb4E9 900000000000000000000 --private-key 0xac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80 --rpc-url local
cast send 0x9fE46736679d2D9a65F0992F2272dE9f3c7fa6e0 "transfer(address to, uint256 value)" 0xF4A4378A91d7aFb2EC4a1bf5d80a21ae87C15e44 1000000000000000000000 --private-key 0xac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80 --rpc-url local
cast send 0x9fE46736679d2D9a65F0992F2272dE9f3c7fa6e0 "transfer(address to, uint256 value)" 0xd8fbBF32Be3b93F4Dc4242C7c1B172335581B534 1000000000000000000000 --private-key 0xac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80 --rpc-url local
cast send 0x9fE46736679d2D9a65F0992F2272dE9f3c7fa6e0 "transfer(address to, uint256 value)" 0x36c3638114334Ac63465466424aF0205aEB41D37 1000000000000000000000 --private-key 0xac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80 --rpc-url local
cast send 0x9fE46736679d2D9a65F0992F2272dE9f3c7fa6e0 "transfer(address to, uint256 value)" 0xC0ac046EF6a2446EBEf325522115E1C6E5AC9E05 1000000000000000000000 --private-key 0xac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80 --rpc-url local
cast send 0x9fE46736679d2D9a65F0992F2272dE9f3c7fa6e0 "transfer(address to, uint256 value)" 0x72851d9F59F27FAFAdfdF739Ea3DdB74D8FDbd2E 1000000000000000000000 --private-key 0xac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80 --rpc-url local
cast send 0x9fE46736679d2D9a65F0992F2272dE9f3c7fa6e0 "transfer(address to, uint256 value)" 0x7Af461Ef23914f581AD5e65d000783e215907100 1000000000000000000000 --private-key 0xac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80 --rpc-url local
cast send 0x9fE46736679d2D9a65F0992F2272dE9f3c7fa6e0 "transfer(address to, uint256 value)" 0x7Af461Ef23914f581AD5e65d000783e215907100 1000000000000000000000 --private-key 0xac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80 --rpc-url local
cast send 0x9fE46736679d2D9a65F0992F2272dE9f3c7fa6e0 "transfer(address to, uint256 value)" 0x7Af461Ef23914f581AD5e65d000783e215907100 1000000000000000000000 --private-key 0xac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80 --rpc-url local
