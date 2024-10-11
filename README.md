# color-blind-simulator
a simple iOS app to demonstrate what the world looks like for people with color vision deficiencies

### Description
Color vision deficiency (CVD) is a common but under-recognized condition that results in decreased ability to discern colors. It is usually hereditary (though there are acquired forms). There are several types depending on which color sensing opsin is missing. CVD is quite common; ***up to*** 1 in 12 males (8%) and 1 in 200 females (0.5%) have CVD. The prevalence of CVD has significant implications for graphic and UX design, as a significant fraction of the audience may not understand your use of color.

### Inspiration
I was talking to my 7 yo about how different people percieve the world differently, and we started talking about color blindness. He understood conceptually, but asked me what it was like to experience the world with color blindness. I said I didn't really know, but thought we could find out together by making a simple iOS app. It turns out in addition to the pedagogical value this app is also useful to double check design choices, and make sure infographics or apps are CVD accessible.

### Implementation
#### Design
- Camera Feed: The app uses AVCaptureSession to capture video frames from the device’s camera in real-time.
- Core Image Filtering: The captured frames are processed using Core Image filters, specifically CIColorMatrix, to adjust the color channels based on the type of color blindness selected.
- User Interface: The app provides a segmented control for switching between different filters (Protanopia, Deuteranopia, Tritanopia, and normal vision). The processed video is displayed using a UIImageView.

#### Filters
Protanopia (Red-Weakness): Red channel is reduced significantly, shifting color perception toward greens and blues.
Deuteranopia (Green-Weakness): Green channel is reduced, with stronger emphasis on reds and blues.
Tritanopia (Blue-Weakness): Blue channel is reduced, shifting perception to reds and greens.

#### Requirements
- iOS 13.0 or later
- Xcode 12 or later
- Swift 5.0

#### Setup and Usage
1. Clone the repository and open the project in Xcode.
2. Build and run the project on an iOS device with a camera.
3. Use the toggle in the app to switch between different color blindness simulations.
