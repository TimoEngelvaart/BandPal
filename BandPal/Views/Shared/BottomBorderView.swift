import SwiftUI

struct BottomBorderView: View {
    var body: some View {
        VStack(alignment: .center, spacing: 0) {
            VStack(alignment: .center, spacing: 0) {
                
                HStack(alignment: .center, spacing: 20) {
                    //Icon + Text
                    VStack(alignment: .center, spacing: 2) {
                        HStack(alignment: .center, spacing: 0) {
                            Image("Home")
                            .frame(width: 19, height: 20)
                        }
                        .padding(.horizontal, 2.5)
                        .padding(.vertical, 2)
                        .frame(width: 24, height: 24, alignment: .center)
                        Text("Home")
                          .font(
                            Font.custom("Urbanist", size: 10)
                              .weight(.medium)
                          )
                          .kerning(0.2)
                          .multilineTextAlignment(.center)
                          .foregroundColor(Color(red: 0.62, green: 0.62, blue: 0.62))
                          .frame(maxWidth: .infinity, alignment: .center)
                    }
                    VStack(alignment: .center, spacing: 2) {
                        HStack(alignment: .center, spacing: 0) {
                            Image("Home")
                            .frame(width: 19, height: 20)
                        }
                        .padding(.horizontal, 2.5)
                        .padding(.vertical, 2)
                        .frame(width: 24, height: 24, alignment: .center)
                        Text("Home")
                          .font(
                            Font.custom("Urbanist", size: 10)
                              .weight(.medium)
                          )
                          .kerning(0.2)
                          .multilineTextAlignment(.center)
                          .foregroundColor(Color(red: 0.62, green: 0.62, blue: 0.62))
                          .frame(maxWidth: .infinity, alignment: .center)
                    }
                    VStack(alignment: .center, spacing: 2) {
                        HStack(alignment: .center, spacing: 0) {
                            Image("Home")
                            .frame(width: 19, height: 20)
                        }
                        .padding(.horizontal, 2.5)
                        .padding(.vertical, 2)
                        .frame(width: 24, height: 24, alignment: .center)
                        Text("Home")
                          .font(
                            Font.custom("Urbanist", size: 10)
                              .weight(.medium)
                          )
                          .kerning(0.2)
                          .multilineTextAlignment(.center)
                          .foregroundColor(Color(red: 0.62, green: 0.62, blue: 0.62))
                          .frame(maxWidth: .infinity, alignment: .center)
                    }
                    
                    .padding(0)
                .frame(maxWidth: .infinity, alignment: .top)
                }
                .padding(.horizontal, 32)
                .padding(.vertical, 0)
                .frame(maxWidth: .infinity, minHeight: 48, maxHeight: 48, alignment: .center)
            }
            .padding(.horizontal, 0)
            .padding(.top, 8)
            .padding(.bottom, 0)
            .frame(width: 428, alignment: .top)
        
            .cornerRadius(24)
        }
        .padding(.horizontal, 0)
        .padding(.top, 8)
        .padding(.bottom, 0)
        .frame(width: 428, alignment: .top)
        .cornerRadius(24)
    }
}

#Preview {
    BottomBorderView()
}
