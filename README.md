# Ruby Vonage WebSockets Voice API Demo App

[![Contributor Covenant](https://img.shields.io/badge/Contributor%20Covenant-v2.0%20adopted-ff69b4.svg)](CODE_OF_CONDUCT.md)
[![MIT licensed](https://img.shields.io/badge/license-MIT-blue.svg)](./LICENSE.txt)

<img src="https://developer.nexmo.com/assets/images/Vonage_Nexmo.svg" height="48px" alt="Nexmo is now known as Vonage" />

This is a demo app showcasing how to build a Ruby app that utilizes [Vonage Voice API WebSockets](https://developer.nexmo.com/voice/voice-api/guides/websockets).

Users call the application and the audio from the call is streamed to the application via a Vonage Video API WebSocket connection. At the conclusion of the call, the user can play the audio from the website.

* [Requirements](#requirements)
* [Installation](#installation)
* [Usage](#usage)
* [License](#license)

## Requirements

This app requires Ruby v2.7 or greater.

## Installation

Once you clone the repository, make sure its dependencies are installed on your local machine:

```bash
$ gem install wavefile
$ gem install faye-websocket
$ gem install json
```

## Usage

This application requires a Vonage provisioned virtual number that is linked to a Voice Voice application. Both of those items can be created from your [Vonage Dashboard](https://dashboard.nexmo.com). The phone number you create in the Dashboard will be the number that you will call to use your application.

You will need to provide an `answer URL` for the application you create that corresponds to the answer route provided in the `app.rb` file. The answer URL needs to be an externally accessible URL that ends with `/webhooks/answer`. For example, if your URL was `example.com`, then your answer URL would be `http://example.com/webhooks/answer`.

![Voice API URL settings](voice_app_url_settings.png)

Next, open up the `app.rb` file in your preferred code editor and add an externally accessible URL for Vonage WebSockets to send data to. 

Once, you have done so, you can run the application by executing the following command:

```bash
$ thin start -R app.rb -p 9292
```

The above command will begin a [thin](https://github.com/macournoyer/thin) web server running on port 9292.

The application is now ready to call. Once you hang up the call, you can visit `localhost:9292` in your browser and play the audio that was recorded via the WebSocket connection.

## License

This library is released under the [MIT License][license]

[license]: LICENSE.txt