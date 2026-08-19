import 'package:flutter/material.dart';

/// Centralized app strings catalog.
class AppStrings {
  static const appName = 'RMScanner AI';
  static const playStoreUrl =
      'https://play.google.com/store/apps/details?id=com.rmscanner.ai';
  static const shareMessage =
      'Hey! Check out $appName, the ultimate document scanner and PDF editor. Download it now: $playStoreUrl';
  static const allTools = 'All Tools';
  static const pdfTools = 'PDF TOOLS';
  static const converters = 'Converters';
  static const privacyAndSecurity = 'Privacy & Security';

  // PDF Tools
  static const mergePdf = 'Merge PDF';
  static const splitPdf = 'Split PDF';
  static const compressPdf = 'Compress PDF';
  static const rotatePdf = 'Rotate PDF';

  // Converters
  static const imageToPdf = 'Image to PDF';
  static const highQuality = 'HIGH QUALITY';
  static const pdfToImage = 'PDF to Image';
  static const fastScan = 'FAST SCAN';
  static const textToPdf = 'Text to PDF';
  static const easyEdit = 'EASY EDIT';
  static const pdfToText = 'PDF to Text';
  static const extractData = 'EXTRACT DATA';

  // Security
  static const lockPdf = 'Lock PDF';
  static const addPasswordProtection = 'Add password protection';
  static const unlockPdf = 'Unlock PDF';
  static const removeDocumentRestrictions = 'Remove document restrictions';
  static const addSignature = 'Add Signature';
  static const digitallySignDocuments = 'Digitally sign documents';
  static const privacyPolicy = 'Privacy Policy';
  static const readOurPrivacyPolicy = 'Read our privacy policy';
  static const contactSupport = 'Contact Support';
  static const reachOutToUs = 'Reach out to us for help';
  static const privacyPolicyUrl = 'https://rmdigital.co.id/kebijakan-privasi/';
  static const supportEmail = 'rmdigital.co.id@gmail.com';

  // Signature flow
  static const signatureSaved = 'Signature saved successfully';
  static const errorPrefix = 'An unexpected error occurred. Please try again.';

  // Draw signature
  static const drawSignature = 'Draw Signature';
  static const pleaseSign = 'Please sign inside the white box below.';
  static const clear = 'Clear';
  static const undo = 'Undo';
  static const confirm = 'Confirm';

  // Signature positioning
  static const dragScaleSignature = 'Drag & Scale Signature';
  static const confirmSaveStamp = 'Confirm & Save Stamp';

  // Onboarding
  static const onboardTitle1 = 'Scan Anywhere';
  static const onboardDesc1 =
      'Easily scan documents on the go with high quality and auto-edge detection.';
  static const onboardTitle2 = 'Smart OCR';
  static const onboardDesc2 =
      'Extract text from your scanned documents in multiple languages instantly.';
  static const onboardTitle3 = 'Organize & Share';
  static const onboardDesc3 =
      'Convert scans to PDF, organize files, and share them securely.';
  static const skip = 'SKIP';
  static const start = 'START';

  // Settings & UI
  static const freeUser = 'Free User';
  static const upgradeToUnlock = 'Upgrade to Unlock All Features';
  static const upgrade = 'Upgrade';
  static const notifyWhenReady = 'Notify When Ready';
  static const mayTakeAWhile = 'This may take a while for large files.';
  static const cacheClearedMessage = 'Cache cleared';
  static const noRecentFiles = 'No recent files';
  static const noFilesFound = 'No files found';
  static const deleteConfirm = 'Delete';

  // Small helper to return a localized value; in future integrate wit
  // `AppLocalizations` and provide per-locale maps.
  static String localized(BuildContext context, String key) {
    // Simple placeholder, currently supports 'title' used on Splash.
    switch (key) {
      case 'title':
        return appName;
      default:
        return key;
    }
  }

  // File action strings
  static const fileOptions = 'File Options';
  static const share = 'Share';
  static const sharedViaRmscanner = 'Shared via $appName';
  static const download = 'Download';
  static const savedToDownloads = 'Saved to Downloads folder';
  static const couldNotSavePermission =
      'Could not save: Please allow storage permission.';
  static const rename = 'Rename';
  static const cancel = 'Cancel';
  static String deleteConfirmation(String fileName) {
    return 'Are you sure you want to delete "$fileName"? This action cannot be undone.';
  }

  static String deletedSuccessfully(String fileType) {
    return '$fileType deleted successfully';
  }

  // PDF Action Helper Strings
  static const enterTextHint = 'Enter text...';
  static const create = 'Create';
  static const pdfCreatedSuccessfully = 'PDF Created Successfully';
  static const textToPdfError =
      'Failed to convert text to PDF. Please try again.';
  static const imageToPdfSuccess = 'Image to PDF Created Successfully';
  static const pdfsMergedSuccess = 'PDFs Merged Successfully';
  static const pageRangeLabel = 'Page Range (e.g., 1,3,5-7)';
  static const pageRangeHint = 'Enter pages to split';
  static const split = 'Split';
  static const invalidPageRange = 'Invalid page range entered';
  static const pdfSplitSuccess = 'PDF Split Successfully';
  static const compressionQuality = 'Compression Quality';
  static const compressLow = 'Low (Faster, larger size)';
  static const compressMedium = 'Medium';
  static const compressHigh = 'High (Slower, smallest size)';
  static const pdfCompressedSuccess = 'PDF Compressed Successfully';
  static const rotationAngle = 'Rotation Angle';
  static const rotate90CW = '90° Clockwise';
  static const rotate180 = '180°';
  static const rotate270CW = '270° Clockwise';
  static const pdfRotatedSuccess = 'PDF Rotated Successfully';
  static const alreadyProtected = 'This PDF is already password protected.';
  static const enterPasswordToProtect =
      'Enter a password to protect this PDF document.';
  static const password = 'Password';
  static const lock = 'Lock';
  static const pdfLockedSuccess = 'PDF Locked Successfully';
  static const notProtected = 'This PDF is not password protected.';
  static const enterPasswordToUnlock =
      'Enter the password to unlock this document.';
  static const unlock = 'Unlock';
  static const pdfUnlockedSuccess = 'PDF Unlocked Successfully';
  static const incorrectPassword = 'Incorrect password. Please try again.';
  static const failedToUnlock = 'Failed to unlock PDF. Please try again.';
  static const pdfToImageSuccess = 'PDF to Image Successful';
  static const selectImageSource = 'Select Image Source';
  static const gallery = 'Gallery';
  static const pickFromGallery = 'Pick an image from your gallery';
  static const camera = 'Camera';
  static const captureNewPhoto = 'Capture a new photo';
  static const pdfToTextSuccess = 'PDF to Text Successful';
  static const ocrErrorPrefix =
      'OCR extraction failed. Please try a clearer image.';

  // Files Screen Strings
  static const sortBy = 'Sort By';
  static const sortDate = 'Date (Newest First)';
  static const sortName = 'Name (A-Z)';
  static const sortSize = 'Size (Largest First)';
  static const searchHint = 'Search documents, PDFs...';
  static const tabRecent = 'Recent';
  static const tabPdfs = 'PDFs';
  static const tabImages = 'Images';
  static const tabOcrText = 'OCR Text';
  static const couldNotOpenFile = 'Could not open the file.';
  static const errorOpeningFile = 'An error occurred while opening the file.';

  // Settings Screen Strings
  static const appLanguage = 'App Language';
  static const theme = 'Theme';
  static const themeLight = 'Light';
  static const themeDark = 'Dark';
  static const themeSystem = 'System';
  static const scanQualityLabel = 'Scan Quality';
  static const defaultPageSizeLabel = 'Default Page Size';
  static const ocrLanguageLabel = 'OCR Language';
  static const clearCacheTitle = 'Clear Cache';
  static String clearCacheConfirm(String size) {
    return 'This will delete all cached files ($size). Continue?';
  }

  // OCR Screen Strings
  static const selectOcrLanguage = 'Select OCR Language';
  static const langEnglish = 'English';
  static const langIndonesian = 'Indonesian';
  static const langHindi = 'Hindi';
  static const langChinese = 'Chinese';
  static const langJapanese = 'Japanese';
  static const langKorean = 'Korean';
  static const extractingFromImage = 'Extracting text from image...';
  static const errorPickingImage =
      'Could not pick the image. Please try again.';
  static const extractingFromPdf = 'Extracting text from PDF...';
  static const errorPickingPdf = 'Could not open the PDF. Please try again.';
  static const extractingFromCapture = 'Extracting text from capture...';
  static const errorCapturingImage =
      'Could not capture photo. Please check your camera.';
  static const textExtractedSuccess = 'Text extracted successfully!';
  static const extractTextTitle = 'Extract Text with AI';
  static const extractTextSubtitle =
      'Select a source to begin extracting text from your documents.';
  static const sourceImage = 'Image';
  static const sourcePdf = 'PDF';
  static const sourceCamera = 'Camera';
  static const captureDocument = 'Capture Document';
  static const selectFile = 'Select File';
  static const textCopied = 'Text copied to clipboard';
  static const scannedTextFromRmscanner = 'Scanned Text from $appName';
  static const errorSharingPrefix =
      'Could not share the document. Please try again.';
  static const savedSuccessTextFile = 'Saved successfully as text file.';
  static const errorSavingDocPrefix =
      'Failed to save the document. Please check storage permissions.';
  static const extractionResults = 'Extraction Results';
  static const copyAction = 'Copy';
  static const documentStatistics = 'Document Statistics';
  static const words = 'words';
  static const characters = 'characters';
  static const extractedText = 'Extracted Text';
  static const noTextExtractedHint = 'No text extracted. Try editing here...';
  static const saveDocument = 'Save Document';

  // Home Screen Strings
  static const convertPhotos = 'Convert photos';
  static const extractOcrSubtitle = 'Extract (OCR)';
  static const convertPdfSubtitle = 'Convert PDF';
  static const createDocSubtitle = 'Create Doc';
  static const scanError =
      'An error occurred during scanning. Please try again.';
  static String permissionRequired(String name) {
    return '$name Permission Required';
  }

  static const cameraPermissionMsg = 'Camera permission is required to scan.';
  static const openSettings = 'Open Settings';
  static const creatingPdf = 'Creating PDF...';

  // Scan Result Screen Strings
  static const imagesSavedSuccessfully = 'image(s) saved successfully';
  static const pdfSavedSuccessfully = 'PDF saved successfully';
  static const scannedDocumentHeader = 'Scanned Document -';
  static const pagesPrefix = 'Pages:';
  static const pagePrefix = 'Page';
  static const documentSavedSuccessfully = 'Document saved successfully';
  static const scannedDocumentsFromRmscanner =
      'Scanned Documents from $appName';
  static const scanResult = 'Scan Result';
  static const failedToLoadImage = 'Failed to load image';
  static const pagesScannedChooseFormat = 'scanned  •  Choose save format';
  static const saveAs = 'Save As';
  static const document = 'Document';
  static const shareScannedPages = 'Share Scanned Pages';
  static const saving = 'Saving...';
  static const typePdf = 'PDF';
  static const typeImage = 'Image';
  static const typeText = 'Text document';
}
