use protostar_contract_01::erc20::ERC20;

use debug::PrintTrait;

use starknet::contract_address_const;
use starknet::ContractAddress;
use starknet::testing::set_caller_address;

const Name: felt252 = 'You SB';
const Symbol: felt252 = 'YSB';

fn init() {
    let caller = contract_address_const::<1>();
    set_caller_address(caller);

    ERC20::constructor(Name, Symbol);
}

#[test]
#[available_gas(2000000)]
fn test_constructor(){
    ERC20::constructor(Name, Symbol);

    ERC20::name().print();
}