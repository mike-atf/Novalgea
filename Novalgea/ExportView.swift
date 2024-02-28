//
//  ExportView.swift
//  Novalgea
//
//  Created by aDev on 22/02/2024.
//

import SwiftUI
import SwiftData
import UniformTypeIdentifiers
import OSLog

struct ExportView: View {
    
    @Environment(\.modelContext) private var modelContext

    @State var showExportDialog = false
    @State var exportURL: URL?
    @State var showAlert = false
    
    var body: some View {
        
        NavigationStack {
            Button {
                compressAndExport()
            } label: {
                Image(systemName: "square.and.arrow.up.on.square.fill").foregroundColor(.blue)
                Text("Export Diary Database file").font(.title)
            }
            .onDisappear {
                Task {
                    await removeExportFile()
                }
            }
        }
    }
    
    private func compressAndExport()  {
        
        Task {
            do {
                exportURL = try await BackupManager.compressModelContainer()
                DispatchQueue.main.async {
                    self.actionSheet()
                }
            } catch {
                if let ie = error as? InternalError {
                    await ErrorManager.addError(error: ie, container: modelContext.container)
                }
            }
        }
    }
    
    func actionSheet() {
        guard let data = exportURL else { return }
        let av = UIActivityViewController(activityItems: [data], applicationActivities: nil)
        if let keyWindow = UIApplication.shared.connectedScenes.compactMap({ ($0 as? UIWindowScene)?.keyWindow }).last {
            keyWindow.rootViewController?.present(av, animated: true, completion: nil)
        }
    }

    
    private func removeExportFile() async {
        
        guard let fileURL = exportURL else {
            return
        }
        
        do {
            try FileManager.default.removeItem(at: fileURL)
        } catch {
            let ierror = InternalError(file: "ExportView", function: "removeExportFile()", appError: "export copy of .sqlite database couldn't be removed", osError: error.localizedDescription)
            await ErrorManager.addError(error: ierror, container: modelContext.container)
        }

        
    }
}

#Preview {
    ExportView()
}
