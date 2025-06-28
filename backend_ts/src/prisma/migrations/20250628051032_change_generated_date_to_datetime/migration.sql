-- DropIndex
DROP INDEX `user_daily_summaries_userId_generatedDate_key` ON `user_daily_summaries`;

-- AlterTable
ALTER TABLE `user_daily_summaries` MODIFY `generatedDate` DATETIME(3) NOT NULL;

-- Update existing data: use createdAt time for existing records to avoid conflicts
UPDATE `user_daily_summaries` 
SET `generatedDate` = `createdAt` 
WHERE TIME(`generatedDate`) = '00:00:00';

-- CreateIndex
CREATE UNIQUE INDEX `user_daily_summaries_userId_generatedDate_key` ON `user_daily_summaries`(`userId`, `generatedDate`);
