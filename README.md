# Nougat

![Build Nougat](https://github.com/Shade-Zepheri/Nougat/workflows/Build%20Nougat/badge.svg) [![Build Status](https://travis-ci.org/Shade-Zepheri/Nougat.svg?branch=master)](https://travis-ci.org/Shade-Zepheri/Nougat) [![Crowdin](https://badges.crowdin.net/nougat/localized.svg)](https://crowdin.com/project/nougat)

An almost 1:1 recreation of the Android notification panel from Android Oreo for iOS. Built to support iOS 10 up to iOS 13.3 on iPhones and iPads.

## Installation
### From an APT Repo
Currently Nougat is in beta stage and available on my beta repo [here](https://shade-zepheri.github.io).

In the future, Nougat will be available on one of the default repo for purchase.

### Compiling from source
If you want to compile Nougat for yourself, you will need to have theos installed (If you don't have `theos` already installed on your computer, follow the steps located [here](https://github.com/theos/theos/wiki/Installation)), then follow these steps:

1. Clone this repository using `git clone https://github.com/Shade-Zepheri/Nougat.git` or your preffered method.
2. `cd` into the cloned `Nougat` folder.
4. run `make do` 
5. Done! 

## Bug Reports

If you encounter any bugs or unexpected crashes, please open an issue [here](https://github.com/Shade-Zepheri/Nougat/issues/new?assignees=&labels=bug&template=bug_report.md&title=)

Fill out the template as best as you can, so I can more easily understand the issue and be able to resolve it quicker.

Opening issues require a github account, if you cannot create one, feel free to email me the bug report from the settings panel.

## Translations

Nougat supports localizations for multiple languages, but help is needed to cover all languages

If you are familiar enough with a language and want to help translate (if it hasn't already been done), you can do so by following these steps:

Crowdin is used in order to streamline and simplify the translating process.
- First, if your desired language isn't already among the supported list (found [here](https://crwd.in/nougat)), please file an issue [here](https://github.com/Shade-Zepheri/Nougat/issues/new?assignees=&labels=enhancement%2C+localization&template=localization-support.md&title=) to let me know what language you would like added. Once added, you can start translating at [https://crowdin.com/project/nougat](https://crowdin.com/project/nougat).
- If your language is already support, head to [https://crowdin.com/project/nougat](https://crowdin.com/project/nougat), select the desired language and begin translating.

New strings may be potentially added over time, so make sure to keep an eye out for new versions to see if any were added.