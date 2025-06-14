-- CreateTable
CREATE TABLE `user_daily_summary_saved_articles` (
    `id` INTEGER NOT NULL AUTO_INCREMENT,
    `userDailySummaryId` INTEGER NOT NULL,
    `savedArticleId` INTEGER NOT NULL,
    `createdAt` DATETIME(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3),
    `updatedAt` DATETIME(3) NOT NULL,

    INDEX `user_daily_summary_saved_articles_userDailySummaryId_idx`(`userDailySummaryId`),
    INDEX `user_daily_summary_saved_articles_savedArticleId_idx`(`savedArticleId`),
    UNIQUE INDEX `user_daily_summary_saved_articles_userDailySummaryId_savedAr_key`(`userDailySummaryId`, `savedArticleId`),
    PRIMARY KEY (`id`)
) DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

-- AddForeignKey
ALTER TABLE `user_daily_summary_saved_articles` ADD CONSTRAINT `user_daily_summary_saved_articles_userDailySummaryId_fkey` FOREIGN KEY (`userDailySummaryId`) REFERENCES `user_daily_summaries`(`id`) ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE `user_daily_summary_saved_articles` ADD CONSTRAINT `user_daily_summary_saved_articles_savedArticleId_fkey` FOREIGN KEY (`savedArticleId`) REFERENCES `saved_articles`(`id`) ON DELETE CASCADE ON UPDATE CASCADE;
