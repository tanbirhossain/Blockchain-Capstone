pragma solidity >=0.4.25 <0.6.0;

import "./ERC721Mintable.sol";
import 'openzeppelin-solidity/contracts/drafts/Counters.sol';

// TODO define a contract call to the zokrates generated solidity contract <Verifier> or <renamedVerifier>
contract Verifier{
        function verifyTransaction(
            uint[2] memory a,
            uint[2] memory a_p,
            uint[2][2] memory b,
            uint[2] memory b_p,
            uint[2] memory c,
            uint[2] memory c_p,
            uint[2] memory h,
            uint[2] memory k,
            uint[2] memory input
        ) public returns (bool r);
}

// TODO define another contract named SolnSquareVerifier that inherits from your ERC721Mintable class
contract SolnSquareVerifier is ERC721Mintable{

    Verifier private verifier;

    using Counters for Counters.Counter;

// TODO define a solutions struct that can hold an index & an address
    struct Solution {
        uint256 index;
        address solutionAddress;
        bool passed;
    }

    Counters.Counter private _currentIndex;

// TODO define a mapping to store unique solutions submitted
    mapping(bytes32 => Solution) _solSubmit; // hash of input[0],input[1] -> solution

// TODO Create an event to emit when a solution is added
    event SolutionAdded(uint256 index, address solutionAddress);

// Contractor function
constructor(address verifierAddress, string memory name, string memory symbol)
            ERC721Mintable(name,symbol) public {
                verifier = Verifier(verifierAddress);
            }

// TODO Create a function to add the solutions to the array and emit the event
function addToSolutions(
            uint[2] memory a,
            uint[2] memory a_p,
            uint[2][2] memory b,
            uint[2] memory b_p,
            uint[2] memory c,
            uint[2] memory c_p,
            uint[2] memory h,
            uint[2] memory k,
            uint[2] memory input
) public {
    bytes32 _solHash = keccak256(abi.encodePacked(input[0], input[1]));
    require(_solSubmit[_solHash].solutionAddress == address(0), "Solution has been added to _solSubmit");

    bool isVerified = verifier.verifyTransaction(a,a_p,b,b_p,c,c_p,h,k,input);
    require(isVerified, "Solution cann't be verified");

    // solution has be verified  add to solutions
    _solSubmit[_solHash] = Solution(_currentIndex.current(), msg.sender, false);
    // emit SolutionAdded
    emit SolutionAdded(_currentIndex.current(), msg.sender);
    _currentIndex.increment();
}


// TODO Create a function to mint new NFT only after the solution has been verified
//  - make sure the solution is unique (has not been used before)
//  - make sure you handle metadata as well as tokenSuplly
function mintNewNFT(uint a, uint b, address to) public
    {
        bytes32 _solHash = keccak256(abi.encodePacked(a, b));
        require(_solSubmit[_solHash].solutionAddress != address(0), "Solution does not exist");
        require(_solSubmit[_solHash].passed == false, "Solution has been passed");
        require(_solSubmit[_solHash].solutionAddress == msg.sender, "Only msg.sender is solutionAddress verified can mint token");
        super.mint(to, _solSubmit[_solHash].index);
        _solSubmit[_solHash].passed = true;
    }
}


























