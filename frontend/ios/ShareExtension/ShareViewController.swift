import Social
import UIKit

class ShareViewController: SLComposeServiceViewController {

    override func isContentValid() -> Bool {
        return true
    }

    override func didSelectPost() {
        handleSharedItems()
        self.extensionContext?.completeRequest(returningItems: [], completionHandler: nil)
    }

    private func handleSharedItems() {
        guard let extensionItem = extensionContext?.inputItems.first as? NSExtensionItem else {
            return
        }
        if let attachments = extensionItem.attachments {
            for attachment in attachments {
                if attachment.hasItemConformingToTypeIdentifier("public.url") {
                    attachment.loadItem(forTypeIdentifier: "public.url", options: nil) { data, _ in
                        if let url = data as? URL {
                            self.openMainApp(with: url.absoluteString)
                        }
                    }
                    return
                }
                if attachment.hasItemConformingToTypeIdentifier("public.text") {
                    attachment.loadItem(forTypeIdentifier: "public.text", options: nil) { data, _ in
                        if let text = data as? String {
                            self.openMainApp(with: text)
                        }
                    }
                    return
                }
            }
        }
    }

    private func openMainApp(with text: String) {
        guard let encoded = text.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed),
              let url = URL(string: "summerymeai://add?text=\(encoded)") else {
            return
        }
        var responder: UIResponder? = self as UIResponder
        while responder != nil {
            if responder!.responds(to: #selector(UIApplication.openURL(_:))) {
                responder?.perform(#selector(UIApplication.openURL(_:)), with: url)
            }
            responder = responder?.next
        }
    }
}
