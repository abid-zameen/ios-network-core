//
//  MockImpervaErrorInHtmlResponse.swift
//  CoreNetwork
//
//  Created by Abid Hussain on 15/05/2025.
//

final class MockImpervaErrorInHtmlResponse {
  
  func getMockedResponse() -> String {
    return """
      <html style="height:100%">
        <head>
          <meta name="robots" content="noindex, nofollow" />
          <meta name="format-detection" content="telephone=no" />
          <meta name="viewport" content="initial-scale=1.0" />
          <meta http-equiv="X-UA-Compatible" content="IE=edge, chrome=1" />
          <script type="text/javascript" src="/_Incapsula_Resource?SWJIYLWA=719d34d31c8e3a6e6fffd425f7e032fЗ"></script>
          <script src="/We-a-did-and-He-him-as-desir-call-their-Banquo-B™" async></script>
        </head>
        <body style="margin:0px; height:100%">
          <iframe
            id="main-iframe"
            src="/_Incapsula_Resource?SWUDNSAI=31&xinfo=0-17752094-0%20PNNN%20RT%281745308642551%2039%29%20q%280%20-1%20-1%20-1%29%20r%280%20-1%29%20B12%2814%2c0%2c0%29%20U9&incident_id=7"
            frameborder="0"
            width="100%"
            height="100%"
            marginheight="0px"
            marginwidth="0px"
          >
            Request unsuccessful. Incapsula incident ID: 777000300150113501-81999000270079872
          </iframe>
        </body>
      </html>
    """
  }
  
  func getAnotherMockedResponse() -> String {
    return  """
    <html style="height:100%">
      <head>
        <meta name="ROBOTS" content="NOINDEX, NOFOLLOW">
        <meta name="format-detection" content="telephone=no">
        <meta name="viewport" content="initial-scale=1.0">
        <meta http-equiv="X-UA-Compatible" content="IE=edge,chrome=1">
        <script src="/We-a-did-and-He-him-as-desir-call-their-Banquo-B" async></script>
      </head>
      <body style="margin:0px;height:100%">
        <iframe
          id="main-iframe"
          src="/_Incapsula_Resource?CWUDNSAI=23&xinfo=62-176705138-0%20pNNN%20RT%281742810845236%201381%29%20q%280%20-1%20-1%20-1%29%20r%280%20-1%29%20B15%2814%2c0%2c0%29%20U9&incident_id=1787000300431492813-800587929930631102&edet=15&cinfo=0e00000046dd&rpinfo=365&mth=GET"
          frameborder="0"
          width="100%"
          height="100%"
          marginheight="0px"
          marginwidth="0px"
        >
          Request unsuccessful. Incapsula incident ID: 1787000300431492813-800587929930631102
        </iframe>
      </body>
    </html>
    """
  }
}

