// SPDX-License-Identifier:MIT
pragma solidity ^0.8.20;

import {Test, console2} from "forge-std/Test.sol";

import { PushCommV3 } from "contracts/PushComm/PushCommV3.sol";
import { CrossChainRequestTypes, CoreTypes } from "../../contracts/libraries/DataTypes.sol";

contract CreateChannelFromComm is Test {
    PushCommV3 public commProxy = PushCommV3(0x96891F643777dF202b153DB9956226112FfA34a9);
    // EPNSCommProxy public epnsCommProxy = EPNSCommProxy(payable(0x96891F643777dF202b153DB9956226112FfA34a9));

    function run() public {
        vm.startBroadcast(vm.envUint("PRIVATE_KEY"));
        address account = vm.addr(vm.envUint("PRIVATE_KEY"));

        uint256 _amount = 50 ether;
        uint256 _gasLimit = 10_000_000;
        CoreTypes.ChannelType channelType = CoreTypes.ChannelType.InterestBearingOpen;
        CrossChainRequestTypes.ChannelPayload memory channelData = CrossChainRequestTypes.ChannelPayload({
            channelAddress: toAsciiString(account),
            channelType: channelType,
            channelExpiry: 0,
            channelIdentity: hex"63b2e80cc302c7a13f5c3b0c1e9ef25c46c7f2de90b7ddbe933f8f518374c6f6"
        });

        CrossChainRequestTypes.SpecificRequestPayload memory _payload = CrossChainRequestTypes.SpecificRequestPayload({
            functionSig: 0xa90521c3,
            amountRecipient: 0x5B9A5152465921307Ca4da7E572bf53f5FA7B671,
            amount: _amount,
            channelData: channelData
        });


        commProxy.createChannel{value: 327242074460000}(_payload, _amount, _gasLimit);

        vm.stopBroadcast();
    }

    function toAsciiString(address x) internal pure returns (string memory) {
        bytes memory s = new bytes(42);
        s[0] = '0';
        s[1] = 'x';
        for (uint i = 0; i < 20; i++) {
            bytes1 b = bytes1(uint8(uint(uint160(x)) / (2**(8*(19 - i)))));
            bytes1 hi = bytes1(uint8(b) / 16);
            bytes1 lo = bytes1(uint8(b) - 16 * uint8(hi));
            s[2+i*2] = char(hi);
            s[3+i*2] = char(lo);            
        }
        return string(s);
    }

    function char(bytes1 b) internal pure returns (bytes1 c) {
        if (uint8(b) < 10) return bytes1(uint8(b) + 0x30);
        else return bytes1(uint8(b) + 0x57);
    }
}