<!--
*** NB: This template was taken from: https://github.com/othneildrew/Best-README-Template/blob/master/README.md?plain=1 
*** For shields, see: https://shields.io/
*** if was further adapted for solidity along example from https://github.com/Cyfrin/6-thunder-loan-audit
-->
<a name="readme-top"></a>

<!-- PROJECT SHIELDS -->
<!--
*** I'm using markdown "reference style" links for readability.
*** Reference links are enclosed in brackets [ ] instead of parentheses ( ).
*** See the bottom of this document for the declaration of the reference variables
*** for contributors-url, forks-url, etc. This is an optional, concise syntax you may use.
*** https://www.markdownguide.org/basic-syntax/#reference-style-links
-->


[![Issues][issues-shield]][issues-url]
[![MIT License][license-shield]][license-url]
[![LinkedIn][linkedin-shield]][linkedin-url]

<!-- PROJECT LOGO -->
<br />
<div align="center">
  <a href="https://github.com/7Cedars/loyalty-program-contracts"> 
    <img src="public/logo.png" alt="Logo" width="500" height="500">
  </a>

<h3 align="center">Governor Separated Powers: Introducing separation of powers to OpenZeppelin's Governor Contract </h3>

  <p align="center">
    An extension that introduces OpenZeppelin's AccessControl restrictions to the governance processes of Governor derived contracts. 
    <br />
    <a href="https://github.com/7Cedars/loyalty-program-contracts"><strong>Explore the docs »</strong></a>
    <br />
    <br />
    <!--NB: TO DO --> 
    <a href="https://loyalty-program-psi.vercel.app">View an example contract on [sepolia.etherscan.io](https://sepolia.etherscan.io/).</a>
    ·
    <a href="https://github.com/7Cedars/loyalty-program-contracts/issues">Report Bug</a>
    ·
    <a href="https://github.com/7Cedars/loyalty-program-contracts/issues">Request Feature</a>
  </p>
</div>

<!-- TABLE OF CONTENTS -->
<details>
  <summary>Table of Contents</summary>
  <ol>
    <li>
      <a href="#about">About</a>
      <ul>
        <li><a href="#built-with">Built With</a></li>
      </ul>
    </li>
    <li>
      <a href="#getting-started">Getting Started</a>
      <ul>
        <li><a href="#prerequisites">Prerequisites</a></li>
        <li><a href="#installation">Installation</a></li>
      </ul>
    </li>
    <li><a href="#usage">Usage</a></li>
    <li><a href="#roadmap">Roadmap</a></li>
    <li><a href="#contributing">Contributing</a></li>
    <li><a href="#license">License</a></li>
    <li><a href="#contact">Contact</a></li>
    <li><a href="#acknowledgments">Acknowledgments</a></li>
  </ol>
</details>



<!-- ABOUT THE PROJECT -->
## About
The extension restricts access to governance processes along restricted roles. 

It does this by relating the `AccessControl` to the `Governor contract` by restricting who can propose, vote on and execute proposals along the access control of an external function.

Why do this?
- It enables the separation of powers in a DAO along various roles.
- This in turn enables the creation of checks and balances between these roles.
- This is a tried and true approach to safeguarding decentralisation of (social, political and economic) assets in light of their tendency to centralise around informal elites.

How does it work? 
- It has to be used with an additional contract that consists of functions that are set as `restricted` and, optionally, set as `onlyGovernance`.
- Proposing, voting and executing proposals always happen in relation to calling these external restricted function.
- The governance process is restricted along the role restrictions of these external functions. 
- For example: When an external function is restricted to `JUDGE_ROLE`, then it is only possible for those holding the `JUDGE_ROLE` to propose, vote on and execute proposals related to this fucntion. 

See the following schema for more detail:
<!-- NB! TODO -->

  <a href="https://github.com/7Cedars/loyalty-program-contracts/blob/master/public/PoCModularLoyaltyProgram.png"> 
    <img src="public/PoCModularLoyaltyProgram.png" alt="Schema Protocol" width="100%" height="100%">
  </a>

### Important files and folders
All solidity contracts can be found in the `src` folder. The folder consists of the following subfolders and files. 

governor-extensions
- `GovernorDividedPowers.sol`: the extension to OpenZeppelin's `governor` contract. Overrides the `_propose`, `_countVote` and `_executeOperations` functions. It aims to keep breaking changes to other extensions to a minimum. 
- `GovernorCountingVoteSuperSimple.sol`: An adaptation of the `GovernorCountingVoteSimple.sol` contract that is included in `governor.sol`. This counting contract does not take delegate weights into consideration. It is especially useful whenever votes among role holders (for instance council members or judges) should _not_ depent on voting power.  

example-laws
- `LawTemplate.sol`: A base contract for functions to use with `GovernorDividedPowers.sol`. Needs to be inherited by contracts that will be called by the `Governor` contract.  
- `LawsAdministrative.sol`: Example function that regulate checks and balances between roles. These all take proposalId from other roles as input variables, to allow their decisions to be checked by a secondary role. IRL, these are called administrative laws.  
- `LawsElectoral.sol`: Example functions for the selection and deselection of accounts to specific roles. Although often not involving a democratic election, these are laws that 'elect' accounts to particular roles. 
- `LawsPublic.sol`: These are any kind of function that does not fall into the electoral or administratice bracket. They are usually functions that guide the functioning of the DAO and related smart contracts. 

example-governance-system
- `GovernedIdentity.sol`: An example implementation of the `GovernorDividedPowers.sol` extension. It builds on the contracts from the `governor-extension` and `example-laws` folders. 

<p align="right">(<a href="#readme-top">back to top</a>)</p>

### Built With
<!-- See for a list of badges: https://github.com/Envoy-VC/awesome-badges -->
<!-- * [![React][React.js]][React-url]  -->
* Solidity 0.8.24
* Foundry 0.2.0
* OpenZeppelin 5.0.2


<p align="right">(<a href="#readme-top">back to top</a>)</p>

<!-- GETTING STARTED -->
## Getting Started

To get a local copy up and running do the following.

### Prerequisites

- [Install git](https://git-scm.com/book/en/v2/Getting-Started-Installing-Git)
  - You'll know you did it right if you can run `git --version` and you see a response like `git version x.x.x`
- [Install foundry](https://getfoundry.sh/)
  - You'll know you did it right if you can run `forge --version` and you see a response like `forge 0.2.0 (816e00b 2023-03-16T00:05:26.396218Z)`


### Clone the repository
<!-- NB: I have to actually follow these steps and check if I missed anyting £todo -->

1. Clone the repo
   ```sh
   git clone https://github.com/7Cedars/governor-restricted-powers
   ```

2. Run make
   ```sh
   cd governor-restricted-powers
   make
   ``` 

### Run the test and build the contracts
3. Run tests
    ```sh
    forge test
    ```

4. Build contracts
    ```sh
   forge build
   ```

<!--  
### Deploy
5. Run deploy script at an EVM compatible Chain
  ```sh
   $ forge script --fork-url <RPC_URL> script/NOT_IMPLEMENTED_YET --broadcast
   ```
-->

<p align="right">(<a href="#readme-top">back to top</a>)</p>

<!-- ROADMAP -->
## Known Issues 

- [ ] This protocol is under active development. Basic functionality is barely implemented. 
- [ ] 

See the [open issues](https://github.com/7Cedars/loyalty-program-contracts/issues) for a full list of proposed features (and known issues).

<p align="right">(<a href="#readme-top">back to top</a>)</p>

<!-- CONTRIBUTING -->
## Contributing

Contributions make the open source community such an amazing place to learn, inspire, and create. Any contributions you make are greatly appreciated.

If you have a suggestion that would make this better, please fork the repo and create a pull request. You can also simply open an issue with the tag "enhancement". Thank you! 

1. Fork the Project
2. Create your Feature Branch (`git checkout -b feature/AmazingFeature`)
3. Commit your Changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the Branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

<p align="right">(<a href="#readme-top">back to top</a>)</p>


<!-- LICENSE -->
## License

Distributed under the MIT License. See `LICENSE.txt` for more information.

<p align="right">(<a href="#readme-top">back to top</a>)</p>

<!-- CONTACT -->
## Contact

Seven Cedars - [@7__Cedars](https://twitter.com/7__Cedars) - cedars7@proton.me

GitHub profile [https://github.com/7Cedars](https://github.com/7Cedars)

<p align="right">(<a href="#readme-top">back to top</a>)</p>



<!-- ACKNOWLEDGMENTS -->
## Acknowledgments
* Patrick Collins
* OpenZeppelin.
* ...  

<p align="right">(<a href="#readme-top">back to top</a>)</p>



<!-- MARKDOWN LINKS & IMAGES -->
<!-- https://www.markdownguide.org/basic-syntax/#reference-style-links -->
<!-- [contributors-shield]: https://img.shields.io/github/contributors/7Cedars/loyalty-program-contracts.svg?style=for-the-badge
[contributors-url]: https://github.com/7Cedars/loyalty-program-contracts/graphs/contributors
[forks-shield]: https://img.shields.io/github/forks/7Cedars/loyalty-program-contracts.svg?style=for-the-badge
[forks-url]: https://github.com/7Cedars/loyalty-program-contracts/network/members
[stars-shield]: https://img.shields.io/github/stars/7Cedars/loyalty-program-contracts.svg?style=for-the-badge
[stars-url]: https://github.com/7Cedars/loyalty-program-contracts/stargazers -->
[issues-shield]: https://img.shields.io/github/issues/7Cedars/loyalty-program-contracts.svg?style=for-the-badge
[issues-url]: https://github.com/7Cedars/loyalty-program-contracts/issues/
[license-shield]: https://img.shields.io/github/license/7Cedars/loyalty-program-contracts.svg?style=for-the-badge
[license-url]: https://github.com/7Cedars/loyalty-program-contracts/LICENSE.txt
[linkedin-shield]: https://img.shields.io/badge/-LinkedIn-black.svg?style=for-the-badge&logo=linkedin&colorB=555
[linkedin-url]: https://linkedin.com/in/linkedin_username
[product-screenshot]: images/screenshot.png
<!-- See list of icons here: https://hendrasob.github.io/badges/ -->
[Next.js]: https://img.shields.io/badge/next.js-000000?style=for-the-badge&logo=nextdotjs&logoColor=white
[Next-url]: https://nextjs.org/
[React.js]: https://img.shields.io/badge/React-20232A?style=for-the-badge&logo=react&logoColor=61DAFB
[React-url]: https://reactjs.org/
[Tailwind-css]: https://img.shields.io/badge/Tailwind_CSS-38B2AC?style=for-the-badge&logo=tailwind-css&logoColor=white
[Tailwind-url]: https://tailwindcss.com/
[Vue.js]: https://img.shields.io/badge/Vue.js-35495E?style=for-the-badge&logo=vuedotjs&logoColor=4FC08D
[Redux]: https://img.shields.io/badge/Redux-593D88?style=for-the-badge&logo=redux&logoColor=white
[Redux-url]: https://redux.js.org/
[Vue-url]: https://vuejs.org/
[Angular.io]: https://img.shields.io/badge/Angular-DD0031?style=for-the-badge&logo=angular&logoColor=white
[Angular-url]: https://angular.io/
[Svelte.dev]: https://img.shields.io/badge/Svelte-4A4A55?style=for-the-badge&logo=svelte&logoColor=FF3E00
[Svelte-url]: https://svelte.dev/
[Laravel.com]: https://img.shields.io/badge/Laravel-FF2D20?style=for-the-badge&logo=laravel&logoColor=white
[Laravel-url]: https://laravel.com
[Bootstrap.com]: https://img.shields.io/badge/Bootstrap-563D7C?style=for-the-badge&logo=bootstrap&logoColor=white
[Bootstrap-url]: https://getbootstrap.com
[JQuery.com]: https://img.shields.io/badge/jQuery-0769AD?style=for-the-badge&logo=jquery&logoColor=white
[JQuery-url]: https://jquery.com 
